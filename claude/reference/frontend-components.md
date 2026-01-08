# Frontend Components Reference

**Load this only when building React/Next.js frontend components.**

## Component Structure

### File Organization
```
components/
├── ui/                    # Generic UI components
│   ├── Button.tsx
│   ├── Input.tsx
│   └── Modal.tsx
├── forms/                 # Form components
│   ├── LoginForm.tsx
│   └── UserForm.tsx
├── layouts/               # Layout components
│   ├── DashboardLayout.tsx
│   └── AuthLayout.tsx
└── features/              # Feature-specific components
    ├── users/
    │   ├── UserList.tsx
    │   └── UserCard.tsx
    └── properties/
        ├── PropertyList.tsx
        └── PropertyCard.tsx
```

### Component Template
```tsx
// components/features/users/UserCard.tsx
import { type FC } from 'react';

interface UserCardProps {
  user: {
    id: string;
    name: string;
    email: string;
    avatar?: string;
  };
  onEdit?: (id: string) => void;
  onDelete?: (id: string) => void;
}

export const UserCard: FC<UserCardProps> = ({ user, onEdit, onDelete }) => {
  return (
    <div className="rounded-lg border p-4 shadow-sm">
      <div className="flex items-center gap-4">
        {user.avatar && (
          <img 
            src={user.avatar} 
            alt={user.name}
            className="h-12 w-12 rounded-full"
          />
        )}
        <div>
          <h3 className="font-semibold">{user.name}</h3>
          <p className="text-sm text-gray-500">{user.email}</p>
        </div>
      </div>
      
      {(onEdit || onDelete) && (
        <div className="mt-4 flex gap-2">
          {onEdit && (
            <button 
              onClick={() => onEdit(user.id)}
              className="text-blue-600 hover:underline"
            >
              Edit
            </button>
          )}
          {onDelete && (
            <button 
              onClick={() => onDelete(user.id)}
              className="text-red-600 hover:underline"
            >
              Delete
            </button>
          )}
        </div>
      )}
    </div>
  );
};
```

## State Management

### React Query for Server State
```tsx
// hooks/useUsers.ts
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';

export function useUsers() {
  return useQuery({
    queryKey: ['users'],
    queryFn: async () => {
      const res = await fetch('/api/v1/users');
      if (!res.ok) throw new Error('Failed to fetch users');
      return res.json();
    },
  });
}

export function useCreateUser() {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: async (userData: CreateUserInput) => {
      const res = await fetch('/api/v1/users', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(userData),
      });
      if (!res.ok) throw new Error('Failed to create user');
      return res.json();
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['users'] });
    },
  });
}
```

### Zustand for Client State
```tsx
// stores/ui-store.ts
import { create } from 'zustand';

interface UIState {
  sidebarOpen: boolean;
  toggleSidebar: () => void;
  modalOpen: string | null;
  openModal: (id: string) => void;
  closeModal: () => void;
}

export const useUIStore = create<UIState>((set) => ({
  sidebarOpen: true,
  toggleSidebar: () => set((state) => ({ sidebarOpen: !state.sidebarOpen })),
  modalOpen: null,
  openModal: (id) => set({ modalOpen: id }),
  closeModal: () => set({ modalOpen: null }),
}));
```

## Form Handling

### React Hook Form + Zod
```tsx
// components/forms/UserForm.tsx
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';

const userSchema = z.object({
  name: z.string().min(2, 'Name must be at least 2 characters'),
  email: z.string().email('Invalid email address'),
  role: z.enum(['user', 'admin']),
});

type UserFormData = z.infer<typeof userSchema>;

interface UserFormProps {
  defaultValues?: Partial<UserFormData>;
  onSubmit: (data: UserFormData) => void;
  isLoading?: boolean;
}

export function UserForm({ defaultValues, onSubmit, isLoading }: UserFormProps) {
  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<UserFormData>({
    resolver: zodResolver(userSchema),
    defaultValues,
  });

  return (
    <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
      <div>
        <label htmlFor="name" className="block text-sm font-medium">
          Name
        </label>
        <input
          id="name"
          {...register('name')}
          className="mt-1 block w-full rounded-md border p-2"
        />
        {errors.name && (
          <p className="mt-1 text-sm text-red-600">{errors.name.message}</p>
        )}
      </div>

      <div>
        <label htmlFor="email" className="block text-sm font-medium">
          Email
        </label>
        <input
          id="email"
          type="email"
          {...register('email')}
          className="mt-1 block w-full rounded-md border p-2"
        />
        {errors.email && (
          <p className="mt-1 text-sm text-red-600">{errors.email.message}</p>
        )}
      </div>

      <button
        type="submit"
        disabled={isLoading}
        className="rounded-md bg-blue-600 px-4 py-2 text-white hover:bg-blue-700 disabled:opacity-50"
      >
        {isLoading ? 'Saving...' : 'Save'}
      </button>
    </form>
  );
}
```

## Loading & Error States

```tsx
// components/ui/QueryWrapper.tsx
interface QueryWrapperProps<T> {
  isLoading: boolean;
  isError: boolean;
  error?: Error | null;
  data: T | undefined;
  children: (data: T) => React.ReactNode;
  loadingFallback?: React.ReactNode;
  errorFallback?: React.ReactNode;
}

export function QueryWrapper<T>({
  isLoading,
  isError,
  error,
  data,
  children,
  loadingFallback,
  errorFallback,
}: QueryWrapperProps<T>) {
  if (isLoading) {
    return loadingFallback ?? <div className="animate-pulse">Loading...</div>;
  }

  if (isError) {
    return errorFallback ?? (
      <div className="text-red-600">
        Error: {error?.message ?? 'Something went wrong'}
      </div>
    );
  }

  if (!data) {
    return <div>No data</div>;
  }

  return <>{children(data)}</>;
}

// Usage
<QueryWrapper {...usersQuery}>
  {(users) => <UserList users={users} />}
</QueryWrapper>
```

## Accessibility Checklist

- [ ] All interactive elements are keyboard accessible
- [ ] Images have alt text
- [ ] Form inputs have labels
- [ ] Color is not the only indicator of state
- [ ] Focus states are visible
- [ ] Proper heading hierarchy (h1 → h2 → h3)
- [ ] ARIA labels where needed
- [ ] Skip links for navigation
