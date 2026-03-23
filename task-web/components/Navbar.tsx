'use client';

import { useRouter } from 'next/navigation';
import { auth } from '@/lib/auth';

export default function Navbar() {
  const router = useRouter();
  const user = auth.getUser();

  const handleLogout = () => {
    auth.clear();
    router.push('/login');
  };

  return (
    <nav className="bg-white shadow-sm border-b">
      <div className="max-w-6xl mx-auto px-4">
        <div className="flex justify-between items-center h-16">
          <div className="flex items-center">
            <h1 className="text-xl font-bold text-blue-600">Task Manager</h1>
          </div>

          {user && (
            <div className="flex items-center gap-4">
              <span className="text-gray-700">
                {user.name}
              </span>
              <button
                onClick={handleLogout}
                className="text-gray-600 hover:text-red-600 transition text-sm font-medium"
              >
                Logout
              </button>
            </div>
          )}
        </div>
      </div>
    </nav>
  );
}
