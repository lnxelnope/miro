'use client';

import { createContext, useContext } from 'react';

export const AdminContext = createContext<{ secret: string }>({ secret: '' });

export function useAdminSecret() {
  return useContext(AdminContext).secret;
}
