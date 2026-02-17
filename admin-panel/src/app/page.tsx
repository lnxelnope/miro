import { redirect } from 'next/navigation';
import { cookies } from 'next/headers';

export default async function RootPage() {
  const cookieStore = await cookies();
  const token = cookieStore.get('admin_token');
  
  if (!token) {
    redirect('/login');
  }
  
  return (
    <div className="min-h-screen bg-gray-50">
      <nav className="bg-white shadow-sm border-b">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between h-16 items-center">
            <h1 className="text-2xl font-bold text-blue-600">MiRO Admin</h1>
            <form action="/api/auth/logout" method="POST">
              <button 
                type="submit"
                className="px-4 py-2 bg-red-500 text-white rounded-lg hover:bg-red-600 transition"
              >
                Logout
              </button>
            </form>
          </div>
        </div>
      </nav>
      
      <main className="max-w-7xl mx-auto py-8 px-4 sm:px-6 lg:px-8">
        <h2 className="text-3xl font-bold mb-6">Dashboard</h2>
        
        <div className="bg-white rounded-xl shadow p-6">
          <p className="text-green-600 font-semibold text-lg">
            Authentication working!
          </p>
          <p className="text-gray-500 mt-2">
            Dashboard metrics will be added in Task 2
          </p>
        </div>
      </main>
    </div>
  );
}
