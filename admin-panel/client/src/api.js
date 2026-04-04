const BASE_URL = '';

async function request(url, options = {}) {
  const token = localStorage.getItem('token');
  const headers = { ...(options.headers || {}) };

  if (token) {
    headers['Authorization'] = `Bearer ${token}`;
  }

  const res = await fetch(`${BASE_URL}${url}`, { ...options, headers });

  if (res.status === 401) {
    localStorage.removeItem('token');
    localStorage.removeItem('user');
    window.location.href = '/login';
    throw new Error('Authentication required');
  }

  if (!res.ok) {
    let message = 'An unexpected error occurred';
    try {
      const body = await res.json();
      message = body.error || message;
    } catch {
      // response body wasn't JSON
    }
    throw new Error(message);
  }

  const contentType = res.headers.get('content-type');
  if (contentType && contentType.includes('application/json')) {
    return res.json();
  }
  return res;
}

export async function apiGet(url) {
  return request(url, { method: 'GET' });
}

export async function apiPost(url, data) {
  if (data instanceof FormData) {
    return request(url, { method: 'POST', body: data });
  }
  return request(url, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(data),
  });
}

export async function apiPut(url, data) {
  if (data instanceof FormData) {
    return request(url, { method: 'PUT', body: data });
  }
  return request(url, {
    method: 'PUT',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(data),
  });
}

export async function apiPatch(url, data) {
  return request(url, {
    method: 'PATCH',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(data),
  });
}

export async function apiDelete(url) {
  return request(url, { method: 'DELETE' });
}
