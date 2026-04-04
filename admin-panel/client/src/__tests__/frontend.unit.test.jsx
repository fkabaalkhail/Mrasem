import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import { render, screen, fireEvent, act } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';

// ── Helpers ──────────────────────────────────────────────────────────

// Mock useAuth so LoginPage doesn't throw outside AuthProvider
vi.mock('../context/AuthContext', () => ({
  useAuth: () => ({
    login: vi.fn(),
    logout: vi.fn(),
    isAuthenticated: false,
    user: null,
    token: null,
  }),
  AuthProvider: ({ children }) => children,
}));

// ── 25.1  LoginPage ─────────────────────────────────────────────────
// Validates: Requirements 1.1

import LoginPage from '../pages/LoginPage';

describe('LoginPage', () => {
  it('renders email and password fields', () => {
    render(
      <MemoryRouter>
        <LoginPage />
      </MemoryRouter>,
    );

    expect(screen.getByLabelText(/email/i)).toBeInTheDocument();
    expect(screen.getByLabelText(/password/i)).toBeInTheDocument();
  });
});

// ── 25.2  Sidebar ───────────────────────────────────────────────────
// Validates: Requirements 10.3

import Sidebar from '../components/Sidebar';

describe('Sidebar', () => {
  it('contains all 6 navigation links', () => {
    render(
      <MemoryRouter>
        <Sidebar />
      </MemoryRouter>,
    );

    const expectedLinks = [
      'Dashboard',
      'Bookings',
      'Restaurants',
      'Activities',
      'Season Events',
      'Users',
    ];

    for (const label of expectedLinks) {
      expect(screen.getByText(label)).toBeInTheDocument();
    }
  });
});

// ── 25.3  Shared components ─────────────────────────────────────────

// ── CityFilter ──
// Validates: Requirements 13.1

import CityFilter from '../components/CityFilter';

describe('CityFilter', () => {
  it('dropdown contains all 6 options', () => {
    render(<CityFilter value="" onChange={vi.fn()} />);

    const options = screen.getAllByRole('option');
    const labels = options.map((o) => o.textContent);

    expect(labels).toEqual([
      'All',
      'Jeddah',
      'Riyadh',
      'Mecca',
      'AlUla',
      'Southern Provence',
    ]);
  });
});

// ── ConfirmDialog ──
// Validates: Requirements 11.3

import ConfirmDialog from '../components/ConfirmDialog';

describe('ConfirmDialog', () => {
  it('calls onConfirm when Delete button is clicked', () => {
    const onConfirm = vi.fn();
    const onCancel = vi.fn();

    render(
      <ConfirmDialog
        open={true}
        onConfirm={onConfirm}
        onCancel={onCancel}
      />,
    );

    fireEvent.click(screen.getByText('Delete'));
    expect(onConfirm).toHaveBeenCalledTimes(1);
  });
});

// ── Toast ──
// Validates: Requirements 11.2

import Toast from '../components/Toast';

describe('Toast', () => {
  beforeEach(() => {
    vi.useFakeTimers();
  });

  afterEach(() => {
    vi.useRealTimers();
  });

  it('auto-dismisses after 3 seconds', () => {
    const onClose = vi.fn();

    render(<Toast message="Saved" onClose={onClose} />);

    expect(onClose).not.toHaveBeenCalled();

    act(() => {
      vi.advanceTimersByTime(3000);
    });

    expect(onClose).toHaveBeenCalledTimes(1);
  });
});
