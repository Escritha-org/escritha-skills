# Reference: escritha-app (React + Vite + Zustand + Tailwind)

## Folder structure

```
src/
├── assets/             # Static images and files bundled with the app
├── components/
│   └── ui/             # Generic UI Kit (Button, Modal, Avatar, etc.)
├── i18n/               # Internationalization
│   └── locales/
├── lib/
│   ├── api.ts          # Central HTTP wrapper (apiFetch)
│   └── document-engine/# Document engine (AST, parsers, serializers)
├── modules/            # Feature-based domain modules
│   ├── <domain>/
│   │   ├── components/ # Components specific to this module
│   │   ├── hooks/      # Hooks and stores for this module
│   │   ├── pages/      # Screen components (composition layer)
│   │   ├── types/      # Interfaces and types for this module
│   │   └── utils/      # Functions, API calls, transformations
│   └── shared/         # Components shared across modules
├── router/             # Route definitions and ProtectedRoute
├── types/              # Global types
└── utils/              # Global utilities
```

### Where to put things
- Component used in only one module → `modules/<domain>/components/`
- Component used across multiple modules → `modules/shared/` or `components/ui/`
- API logic for a module → `modules/<domain>/utils/<domain>Api.ts`
- Zustand store for a module → `modules/<domain>/hooks/use<Domain>Store.ts`
- Types for a module → `modules/<domain>/types/`
- Global types → `src/types/`

---

## Creating a new module

Required structure:

```
src/modules/<lowercase-kebab-case>/    ← always lowercase kebab-case
├── components/
│   └── MyComponent.tsx                ← PascalCase for component files
├── hooks/
│   └── use<Name>Store.ts
├── pages/
│   └── <Name>Page.tsx
├── types/
│   └── index.ts
└── utils/
    └── <name>Api.ts
```

**Important**: the module directory is always **lowercase** (`modules/my-module`), even if the module name is PascalCase internally. The `modules/Home` pattern (PascalCase directory) is a historical inconsistency — do not replicate it.

---

## Component pattern

### React component structure
```tsx
// src/modules/<domain>/components/MyComponent.tsx

interface MyComponentProps {
  title: string;
  onConfirm: () => void;
  variant?: 'primary' | 'secondary';
  disabled?: boolean;
}

export const MyComponent: React.FC<MyComponentProps> = ({
  title,
  onConfirm,
  variant = 'primary',
  disabled = false,
}) => {
  // 1. hooks first
  const { data, isLoading } = useMyData();

  // 2. handlers
  const handleClick = () => {
    onConfirm();
  };

  // 3. render
  return (
    <div className="flex flex-col gap-4">
      <h2 style={{ color: 'var(--text-primary)' }}>{title}</h2>
      <button onClick={handleClick} disabled={disabled}>
        Confirm
      </button>
    </div>
  );
};

export default MyComponent;
```

Rules:
- Props always typed with `interface <Name>Props`
- Callback props: prefix with `on` (e.g. `onConfirm`, `onChange`, `onClose`)
- Export both named and default (both are accepted, but keep consistency within the module)
- Use `React.FC<Props>` with explicit typing

---

## Styling

The project uses **Tailwind + CSS variables** from the design system. Never use hardcoded colors.

```tsx
// ✅ Correct — uses CSS variable from the design system
<div style={{ background: 'var(--bg-primary)', color: 'var(--text-primary)' }}>

// ✅ Correct — Tailwind classes for layout and spacing
<div className="flex flex-col gap-4 p-6 rounded-lg">

// ❌ Wrong — hardcoded color
<div style={{ background: '#ffffff', color: '#333333' }}>
```

CSS variables are defined in `src/index.css`: `--bg-primary`, `--accent`, `--error`, `--text-primary`, among others.

For components with contract/workspace theming, always use `style={{ ... }}` with dynamic CSS variables.

---

## API calls

### Central wrapper
All requests go through `src/lib/api.ts` via `apiFetch`. **Never** use `fetch` directly in components.

```ts
// src/modules/<domain>/utils/<domain>Api.ts
import { apiFetch } from '@lib/api';

export interface MyResource {
  id: string;
  name: string;
}

export async function getMyResource(id: string): Promise<MyResource> {
  return apiFetch<MyResource>(`/my-resource/${id}`);
}

export async function createMyResource(payload: Omit<MyResource, 'id'>): Promise<MyResource> {
  return apiFetch<MyResource>('/my-resource', {
    method: 'POST',
    body: JSON.stringify(payload),
  });
}
```

### Error handling in API calls
```ts
// apiFetch already handles 401 automatically (redirects to /login)
// For other errors, handle at the hook/component level:

try {
  const resource = await getMyResource(id);
  toast.success('Recurso carregado com sucesso!');
} catch (error) {
  toast.error('Não foi possível carregar o recurso.');
  // Never expose technical messages to the user — use Portuguese messages
}
```

### Available import aliases
```ts
import { apiFetch } from '@lib/api';
import { MyComponent } from '@modules/shared/MyComponent';
import { formatDate } from '@utils/formatDate';
// Never use relative paths that cross module boundaries: '../../../lib/api'
```

---

## State management (Zustand)

### Creating a new store
```ts
// src/modules/<domain>/hooks/use<Domain>Store.ts
import { create } from 'zustand';

interface <Domain>State {
  items: MyResource[];
  isLoading: boolean;
  setItems: (items: MyResource[]) => void;
  setLoading: (loading: boolean) => void;
  reset: () => void;
}

const initialState = {
  items: [],
  isLoading: false,
};

export const use<Domain>Store = create<<Domain>State>()((set) => ({
  ...initialState,
  setItems: (items) => set({ items }),
  setLoading: (isLoading) => set({ isLoading }),
  reset: () => set(initialState),
}));
```

Zustand rules:
- Always export with the `use` prefix (`use<Domain>Store`)
- Always include a `reset()` action to clear state
- Use `persist` only when state needs to survive a page refresh (e.g. auth, preferences)
- Never access the `auth` store directly in components — always use `useAuthStore`

---

## Frontend authentication

The JWT token is managed by `useAuthStore` (with `persist` to localStorage).

To check if the user is authenticated in a component:
```ts
import { useAuthStore } from '@modules/auth/hooks/useAuthStore';

const { token, user } = useAuthStore();
```

`apiFetch` already injects `Authorization: Bearer <token>` automatically in all requests. Do not pass the token manually.

For protected routes, use `ProtectedRoute` from `src/router/`:
```tsx
<Route element={<ProtectedRoute />}>
  <Route path="/dashboard" element={<DashboardPage />} />
</Route>
```

---

## Page pattern (composition layer)

Pages live in `pages/` and compose other components while orchestrating hooks:

```tsx
// src/modules/<domain>/pages/<Domain>Page.tsx
export const <Domain>Page: React.FC = () => {
  const { data, isLoading, error } = use<Domain>Data();

  if (isLoading) return <LoadingSpinner />;
  if (error) return <ErrorMessage message={error} />;

  return (
    <AppLayout>
      <MyComponentA data={data} />
      <MyComponentB onAction={handleAction} />
    </AppLayout>
  );
};
```

Pages **do not** make API calls directly — they delegate to hooks (`use<Domain>Data`).

---

## User feedback

Always use `react-hot-toast` for notifications:

```ts
import toast from 'react-hot-toast';

// ✅ Messages always in Portuguese (pt-BR)
toast.success('Seção salva com sucesso!');
toast.error('Não foi possível salvar a seção.');
toast.loading('Gerando PDF...');
```

---

## Tests

- Framework: **Vitest**
- File: `<n>.test.ts` inside a `__tests__/` folder
- Default DOM environment: add `// @vitest-environment jsdom` at the top of the file

```ts
// @vitest-environment jsdom
import { describe, expect, it } from 'vitest';

describe('My feature', () => {
  it('should do X when Y', () => {
    expect(myFunction()).toBe(expectedResult);
  });
});
```