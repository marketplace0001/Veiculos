const API = '/api';

export type Vehicle = {
  id: number;
  brand: string;
  model: string;
  version: string;
  yearModel: number;
  price: number;
  mileage: number;
  transmission: string;
  fuel: string;
  imageUrl?: string;
  status: string;
  store: {
    id: number;
    name: string;
    whatsapp: string;
    city: { name: string; state: string };
  };
};

export type RentalVehicle = {
  id: number;
  brand: string;
  model: string;
  version: string;
  yearModel: number;
  category: string;
  transmission: string;
  fuel: string;
  seats: number;
  airConditioning: boolean;
  dailyRate: number;
  weeklyRate?: number;
  monthlyRate?: number;
  depositAmount?: number;
  unlimitedMileage: boolean;
  minimumAge?: number;
  imageUrl?: string;
  status: string;
  rentalRules?: string;
  store: {
    id: number;
    name: string;
    whatsapp: string;
    city: { name: string; state: string };
  };
};

export type Session = {
  token: string;
  role: 'ADMIN' | 'DEALER' | 'RENTAL' | 'CONSUMER';
  name: string;
  storeId?: number;
};

export function getSession(): Session | null {
  try {
    return JSON.parse(localStorage.getItem('am_session') || 'null');
  } catch {
    return null;
  }
}

export function setSession(session: Session | null): void {
  if (session) {
    localStorage.setItem('am_session', JSON.stringify(session));
  } else {
    localStorage.removeItem('am_session');
  }
}

async function req<T = any>(path: string, init: RequestInit = {}): Promise<T> {
  const session = getSession();
  const headers: Record<string, string> = {
    'Content-Type': 'application/json',
    ...((init.headers || {}) as Record<string, string>)
  };

  if (session?.token) {
    headers.Authorization = `Bearer ${session.token}`;
  }

  const response = await fetch(`${API}${path}`, {
    ...init,
    headers
  });

  if (!response.ok) {
    let message = `HTTP ${response.status}`;
    try {
      const body = await response.json();
      message = body?.message || body?.error || message;
    } catch {
      try {
        const text = await response.text();
        if (text) message = text;
      } catch {
        // Mantem a mensagem HTTP padrao.
      }
    }
    throw new Error(message);
  }

  if (response.status === 204) {
    return null as T;
  }

  return response.json() as Promise<T>;
}

export const api = {
  vehicles: () => req<Vehicle[]>('/public/vehicles'),
  rentals: () => req<RentalVehicle[]>('/public/rentals'),
  stores: () => req<any[]>('/public/stores'),
  cities: () => req<any[]>('/public/cities'),

  login: (email: string, password: string) =>
    req<Session>('/auth/login', {
      method: 'POST',
      body: JSON.stringify({ email, password })
    }),

  lead: (body: any) =>
    req('/leads', {
      method: 'POST',
      body: JSON.stringify(body)
    }),

  rentalRequest: (body: any) =>
    req('/public/rentals/requests', {
      method: 'POST',
      body: JSON.stringify(body)
    }),

  dealerVehicles: () => req<any[]>('/dealer/vehicles'),
  dealerLeads: () => req<any[]>('/dealer/leads'),
  dealerCreateVehicle: (body: any) =>
    req('/dealer/vehicles', {
      method: 'POST',
      body: JSON.stringify(body)
    }),

  rentalVehicles: () => req<any[]>('/rental/vehicles'),
  rentalRequests: () => req<any[]>('/rental/requests'),
  rentalCreateVehicle: (body: any) =>
    req('/rental/vehicles', {
      method: 'POST',
      body: JSON.stringify(body)
    }),

  adminStats: () => req<any>('/admin/stats'),
  adminStores: () => req<any[]>('/admin/stores'),
  adminVehicles: () => req<any[]>('/admin/vehicles'),
  adminLeads: () => req<any[]>('/admin/leads'),
  adminRentals: () => req<any[]>('/admin/rentals'),
  adminRentalRequests: () => req<any[]>('/admin/rental-requests')
};
