# Reference: escritha-api (NestJS + Prisma)

## Folder structure

```
src/
├── core/               # Cross-cutting concerns: guards, decorators, filters, global interceptors
│   ├── decorators/
│   ├── filters/
│   ├── guards/
│   └── interceptors/
├── shared/             # Resources shared across modules
│   ├── constants/      # APP_CONSTANTS and similar
│   ├── dto/            # Generic DTOs (PaginationDto, BaseResponseDto)
│   ├── enums/          # Global enums
│   ├── interfaces/     # ApiResponse, ErrorResponse, PaginatedResponse
│   ├── prisma/         # PrismaService
│   ├── types/          # Auxiliary types (e.g. request-with-user.type)
│   └── utils/          # Global utility functions
├── features/           # Large, composed feature sets
│   └── edition/        # e.g. compilation, conversion, section, pdf, footnote
└── <domain>/           # Each domain has its own folder
    ├── dto/
    ├── <domain>.module.ts
    ├── <domain>.controller.ts
    └── <domain>.service.ts
```

### Where to put things
- Logic reused across multiple modules → `src/shared/utils/`
- Guard/interceptor/filter applied globally → `src/core/`
- DTO used by only one module → `src/<domain>/dto/`
- DTO used by multiple modules → `src/shared/dto/`
- Large feature with several sub-responsibilities → `src/features/<name>/`

---

## Creating a new domain module

Required structure for every new module:

```
src/<kebab-case-name>/
├── dto/
│   ├── create-<name>.dto.ts
│   └── update-<name>.dto.ts
├── <name>.module.ts
├── <name>.controller.ts
├── <name>.service.ts
└── index.ts            ← barrel export
```

The `index.ts` must re-export everything:
```ts
export * from './<name>.module';
export * from './<name>.service';
export * from './<name>.controller';
```

Register the module in `src/app.module.ts` under the correct section (feature, admin, or cross-cutting).

---

## Controller pattern

```ts
@Controller('my-resource')           // kebab-case, plural when it makes sense
export class MyResourceController {

  constructor(private readonly myResourceService: MyResourceService) {}

  @Get()
  findAll(@Req() req: RequestWithUser) {
    return this.myResourceService.findAll(req.user.id);
  }

  @Post()
  create(@Body() dto: CreateMyResourceDto, @Req() req: RequestWithUser) {
    return this.myResourceService.create(dto, req.user.id);
  }
}
```

**Do not** apply `@UseGuards(AuthGuard('jwt'))` manually — `JwtAuthGuard` is already global.
Use `@Public()` for routes that do not require authentication.

---

## DTO pattern

```ts
// src/<domain>/dto/create-<domain>.dto.ts
import { IsString, IsNotEmpty, IsOptional, IsUUID } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateMyResourceDto {
  @ApiProperty({ description: 'Field description' })
  @IsString()
  @IsNotEmpty()
  name: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsUUID()
  workspaceId?: string;
}
```

DTO rules:
- Always use `class-validator` for validation (never validate manually in the service)
- Always annotate with `@ApiProperty()` for Swagger documentation
- Never reuse the same DTO for create and update — create separate `CreateDto` and `UpdateDto`
- `UpdateDto` may extend `PartialType(CreateDto)` from `@nestjs/mapped-types`

---

## Success response pattern

The global `TransformInterceptor` already wraps every response in:
```json
{
  "success": true,
  "data": <controller return value>,
  "timestamp": "2026-03-20T12:00:00.000Z"
}
```

Therefore, **never wrap the return manually** in the controller. Just return the data:
```ts
// ✅ Correct
return this.service.create(dto);

// ❌ Wrong
return { success: true, data: this.service.create(dto) };
```

**Exception**: webhook routes and redirects use `@Res()` with custom responses — keep that pattern only where it already exists.

---

## Error pattern

Always use `HttpException` or its subclasses (`NotFoundException`, `BadRequestException`, etc.):
```ts
import { NotFoundException } from '@nestjs/common';

if (!project) {
  throw new NotFoundException('Projeto não encontrado');
}
```

The global `AllExceptionsFilter` captures and formats the error as:
```json
{
  "statusCode": 404,
  "timestamp": "2026-03-20T12:00:00.000Z",
  "path": "/api/projects/abc",
  "method": "GET",
  "message": ["Projeto não encontrado"]
}
```

---

## Authentication and authorization

### Authentication (who the user is)
The `JwtAuthGuard` is already global and protects all routes. For public routes:
```ts
import { Public } from '../core/decorators/public.decorator';

@Public()
@Post('login')
login(@Body() dto: LoginDto) { ... }
```

The authenticated user is available at `req.user`:
```ts
// src/shared/types/request-with-user.type.ts
// { id: string, email: string, role: Role }
```

### Role-based authorization
```ts
import { Roles } from '../core/decorators/roles.decorator';
import { Role } from '../auth/enums/role.enum';

@Roles(Role.MASTER)
@Get('admin/report')
getReport() { ... }
```

### Workspace-based authorization
```ts
import { WorkspaceRoles } from '../core/decorators/workspace-roles.decorator';
import { WorkspaceRole } from '../auth/enums/workspace-role.enum';

@WorkspaceRoles(WorkspaceRole.OWNER, WorkspaceRole.EDITOR)
@Put(':id')
update(...) { ... }
```

`WorkspaceRolesGuard` automatically extracts `workspaceId` from `params`, `query`, `body`, or the `x-workspace-id` header.

---

## Database (Prisma)

### Using PrismaService
Inject via constructor:
```ts
constructor(private readonly prisma: PrismaService) {}
```

`PrismaService` lives in `src/shared/prisma/` and is exported from `src/shared/index.ts`.

### Schema conventions
- Models (entities): `PascalCase` (`User`, `Project`, `Workspace`)
- Fields: `snake_case` in the database with `@map()` when TypeScript uses `camelCase`:
```prisma
model Project {
  id          String   @id @default(uuid())
  createdAt   DateTime @default(now()) @map("created_at")
  updatedAt   DateTime @updatedAt @map("updated_at")
  workspaceId String   @map("workspace_id")

  workspace   Workspace @relation(fields: [workspaceId], references: [id], onDelete: Cascade)

  @@map("projects")
}
```

### Migrations
- Always generate via CLI: `npx prisma migrate dev --name description_of_change`
- Name in descriptive `snake_case`: `add_cover_table`, `add_workspace_roles`
- Never edit migrations that have already been applied in production

---

## Exports and imports

```ts
// ✅ Always named exports, never default
export class ProjectService { ... }
export class ProjectController { ... }

// ✅ Relative imports for files within the same module
import { CreateProjectDto } from './dto/create-project.dto';

// ✅ Use the shared barrel to import global utilities
import { PrismaService } from '../shared';

// ❌ Never absolute imports without a configured alias
```

---

## Tests

- File: `<name>.spec.ts` in the same directory as the file under test
- Framework: Jest + `@nestjs/testing`
- Always mock `PrismaService` in service tests
```ts
const module = await Test.createTestingModule({
  providers: [
    MyResourceService,
    { provide: PrismaService, useValue: { myModel: { findMany: jest.fn() } } },
  ],
}).compile();
```