'use client';

import { formatDistanceToNow } from 'date-fns';
import { Activity, Zap, Gift, TrendingUp, Star } from 'lucide-react';

interface Activity {
  id: string;
  type: string;
  amount: number;
  description: string;
  userName: string;
  miroId: string;
  createdAt: string;
}

interface RecentActivitiesProps {
  activities: Activity[];
  isLoading?: boolean;
}

export function RecentActivities({ activities, isLoading }: RecentActivitiesProps) {
  if (isLoading) {
    return (
      <div className="bg-white rounded-xl shadow p-6">
        <h3 className="text-lg font-semibold mb-4">Recent Activities</h3>
        <div className="space-y-4">
          {[1, 2, 3, 4, 5].map((i) => (
            <div key={i} className="flex items-center space-x-3 animate-pulse">
              <div className="w-10 h-10 bg-gray-200 rounded-full"></div>
              <div className="flex-1">
                <div className="h-4 bg-gray-200 rounded w-3/4 mb-2"></div>
                <div className="h-3 bg-gray-200 rounded w-1/2"></div>
              </div>
            </div>
          ))}
        </div>
      </div>
    );
  }

  const getActivityIcon = (type: string) => {
    switch (type) {
      case 'ai_analysis':
        return <Zap className="w-5 h-5 text-yellow-600" />;
      case 'daily_check_in':
        return <Star className="w-5 h-5 text-blue-600" />;
      case 'challenge_reward':
        return <TrendingUp className="w-5 h-5 text-green-600" />;
      case 'welcome_gift':
        return <Gift className="w-5 h-5 text-purple-600" />;
      default:
        return <Activity className="w-5 h-5 text-gray-600" />;
    }
  };

  const getActivityColor = (amount: number) => {
    return amount > 0 ? 'text-green-600' : 'text-red-600';
  };

  return (
    <div className="bg-white rounded-xl shadow p-6">
      <h3 className="text-lg font-semibold mb-4">Recent Activities</h3>
      
      {activities.length === 0 ? (
        <p className="text-gray-500 text-center py-8">No recent activities</p>
      ) : (
        <div className="space-y-4">
          {activities.map((activity) => (
            <div key={activity.id} className="flex items-start space-x-3 pb-4 border-b last:border-b-0">
              <div className="p-2 bg-gray-50 rounded-lg">
                {getActivityIcon(activity.type)}
              </div>
              
              <div className="flex-1 min-w-0">
                <div className="flex items-center justify-between">
                  <p className="text-sm font-medium text-gray-900 truncate">
                    {activity.userName}
                    {activity.miroId && (
                      <span className="text-gray-500 ml-2 text-xs">
                        ({activity.miroId})
                      </span>
                    )}
                  </p>
                  <span className={`text-sm font-semibold ${getActivityColor(activity.amount)}`}>
                    {activity.amount > 0 ? '+' : ''}{activity.amount} ⚡
                  </span>
                </div>
                
                <p className="text-sm text-gray-600 mt-1">
                  {activity.description || activity.type.replace(/_/g, ' ')}
                </p>
                
                <p className="text-xs text-gray-400 mt-1">
                  {formatDistanceToNow(new Date(activity.createdAt), { addSuffix: true })}
                </p>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
