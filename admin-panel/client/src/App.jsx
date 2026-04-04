import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider, useAuth } from './context/AuthContext';
import Layout from './components/Layout';
import LoginPage from './pages/LoginPage';

import DashboardPage from './pages/DashboardPage';
import BookingsPage from './pages/BookingsPage';
import BookingDetailPage from './pages/BookingDetailPage';
import RestaurantsPage from './pages/RestaurantsPage';
import RestaurantFormPage from './pages/RestaurantFormPage';
import ActivitiesPage from './pages/ActivitiesPage';
import ActivityFormPage from './pages/ActivityFormPage';
import SeasonEventsPage from './pages/SeasonEventsPage';
import SeasonEventFormPage from './pages/SeasonEventFormPage';
import UsersPage from './pages/UsersPage';
import UserDetailPage from './pages/UserDetailPage';

function ProtectedRoute({ children }) {
  const { isAuthenticated } = useAuth();
  if (!isAuthenticated) {
    return <Navigate to="/login" replace />;
  }
  return children;
}

export default function App() {
  return (
    <BrowserRouter>
      <AuthProvider>
        <Routes>
          <Route path="/login" element={<LoginPage />} />

          <Route
            element={
              <ProtectedRoute>
                <Layout />
              </ProtectedRoute>
            }
          >
            <Route index element={<DashboardPage />} />
            <Route path="bookings" element={<BookingsPage />} />
            <Route path="bookings/:id" element={<BookingDetailPage />} />
            <Route path="restaurants" element={<RestaurantsPage />} />
            <Route path="restaurants/new" element={<RestaurantFormPage />} />
            <Route path="restaurants/:id/edit" element={<RestaurantFormPage />} />
            <Route path="activities" element={<ActivitiesPage />} />
            <Route path="activities/new" element={<ActivityFormPage />} />
            <Route path="activities/:id/edit" element={<ActivityFormPage />} />
            <Route path="season-events" element={<SeasonEventsPage />} />
            <Route path="season-events/new" element={<SeasonEventFormPage />} />
            <Route path="season-events/:id/edit" element={<SeasonEventFormPage />} />
            <Route path="users" element={<UsersPage />} />
            <Route path="users/:id" element={<UserDetailPage />} />
          </Route>
        </Routes>
      </AuthProvider>
    </BrowserRouter>
  );
}
