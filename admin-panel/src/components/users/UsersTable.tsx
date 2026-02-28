'use client';

import {
  useReactTable,
  getCoreRowModel,
  flexRender,
  ColumnDef,
} from '@tanstack/react-table';
import { formatDistanceToNow } from 'date-fns';
import { ChevronLeft, ChevronRight } from 'lucide-react';

interface User {
  id: string;
  miroId: string;
  email: string;
  displayName: string;
  balance: number;
  createdAt: string | null;
  lastActiveAt: string | null;
  streakTier: string;
  currentStreak: number;
  isBanned: boolean;
}

interface UsersTableProps {
  users: User[];
  totalPages: number;
  currentPage: number;
  onPageChange: (page: number) => void;
  onUserClick: (userId: string) => void;
  isLoading?: boolean;
}

export function UsersTable({
  users,
  totalPages,
  currentPage,
  onPageChange,
  onUserClick,
  isLoading,
}: UsersTableProps) {
  const getStreakTierBadge = (tier: string) => {
    const colors: Record<string, string> = {
      bronze: 'bg-orange-100 text-orange-800',
      silver: 'bg-gray-100 text-gray-800',
      gold: 'bg-yellow-100 text-yellow-800',
      diamond: 'bg-blue-100 text-blue-800',
      none: 'bg-gray-50 text-gray-500',
    };

    return (
      <span className={`px-2 py-1 rounded-full text-xs font-medium ${colors[tier] || colors.none}`}>
        {tier === 'none' ? 'No Streak' : tier.toUpperCase()}
      </span>
    );
  };

  const columns: ColumnDef<User>[] = [
    {
      accessorKey: 'miroId',
      header: 'MiRO ID',
      cell: ({ row }) => (
        <span className="font-mono text-sm font-medium">{row.original.miroId}</span>
      ),
    },
    {
      accessorKey: 'displayName',
      header: 'Name',
      cell: ({ row }) => (
        <div>
          <div className="font-medium">{row.original.displayName || 'N/A'}</div>
          <div className="text-sm text-gray-500">{row.original.email}</div>
        </div>
      ),
    },
    {
      accessorKey: 'balance',
      header: 'Balance',
      cell: ({ row }) => (
        <span className="font-semibold">
          {row.original.balance} ⚡
        </span>
      ),
    },
    {
      accessorKey: 'streakTier',
      header: 'Streak',
      cell: ({ row }) => (
        <div className="space-y-1">
          {getStreakTierBadge(row.original.streakTier)}
          <div className="text-xs text-gray-500">
            {row.original.currentStreak} days
          </div>
        </div>
      ),
    },
    {
      accessorKey: 'lastActiveAt',
      header: 'Last Active',
      cell: ({ row }) => {
        if (!row.original.lastActiveAt) return <span className="text-gray-400">Never</span>;
        return (
          <span className="text-sm text-gray-600">
            {formatDistanceToNow(new Date(row.original.lastActiveAt), { addSuffix: true })}
          </span>
        );
      },
    },
    {
      accessorKey: 'createdAt',
      header: 'Joined',
      cell: ({ row }) => {
        if (!row.original.createdAt) return <span className="text-gray-400">Unknown</span>;
        return (
          <span className="text-sm text-gray-600">
            {formatDistanceToNow(new Date(row.original.createdAt), { addSuffix: true })}
          </span>
        );
      },
    },
    {
      id: 'actions',
      header: 'Status',
      cell: ({ row }) => (
        <div>
          {row.original.isBanned ? (
            <span className="px-2 py-1 bg-red-100 text-red-800 rounded text-xs font-medium">
              BANNED
            </span>
          ) : (
            <span className="px-2 py-1 bg-green-100 text-green-800 rounded text-xs font-medium">
              ACTIVE
            </span>
          )}
        </div>
      ),
    },
  ];

  const table = useReactTable({
    data: users,
    columns,
    getCoreRowModel: getCoreRowModel(),
  });

  if (isLoading) {
    return (
      <div className="bg-white rounded-xl shadow">
        <div className="p-6 space-y-4">
          {[1, 2, 3, 4, 5].map((i) => (
            <div key={i} className="animate-pulse flex space-x-4">
              <div className="flex-1 space-y-3">
                <div className="h-4 bg-gray-200 rounded w-3/4"></div>
                <div className="h-4 bg-gray-200 rounded w-1/2"></div>
              </div>
            </div>
          ))}
        </div>
      </div>
    );
  }

  return (
    <div className="bg-white rounded-xl shadow overflow-hidden">
      <div className="overflow-x-auto">
        <table className="min-w-full divide-y divide-gray-200">
          <thead className="bg-gray-50">
            {table.getHeaderGroups().map((headerGroup) => (
              <tr key={headerGroup.id}>
                {headerGroup.headers.map((header) => (
                  <th
                    key={header.id}
                    className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"
                  >
                    {flexRender(header.column.columnDef.header, header.getContext())}
                  </th>
                ))}
              </tr>
            ))}
          </thead>
          <tbody className="bg-white divide-y divide-gray-200">
            {table.getRowModel().rows.map((row) => (
              <tr
                key={row.id}
                onClick={() => onUserClick(row.original.id)}
                className="hover:bg-gray-50 cursor-pointer transition"
              >
                {row.getVisibleCells().map((cell) => (
                  <td key={cell.id} className="px-6 py-4 whitespace-nowrap">
                    {flexRender(cell.column.columnDef.cell, cell.getContext())}
                  </td>
                ))}
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {/* Pagination */}
      <div className="bg-gray-50 px-6 py-4 flex items-center justify-between border-t">
        <div className="text-sm text-gray-700">
          Page {currentPage} of {totalPages}
        </div>
        <div className="flex space-x-2">
          <button
            onClick={() => onPageChange(currentPage - 1)}
            disabled={currentPage === 1}
            className="px-3 py-1 border rounded-lg disabled:opacity-50 disabled:cursor-not-allowed hover:bg-white transition"
          >
            <ChevronLeft className="w-5 h-5" />
          </button>
          <button
            onClick={() => onPageChange(currentPage + 1)}
            disabled={currentPage === totalPages}
            className="px-3 py-1 border rounded-lg disabled:opacity-50 disabled:cursor-not-allowed hover:bg-white transition"
          >
            <ChevronRight className="w-5 h-5" />
          </button>
        </div>
      </div>
    </div>
  );
}
