# Autenticacion JWT

Documentacion del sistema de autenticacion JWT.

## Flujo de Autenticacion

```
1. Registro
   Cliente -> POST /api/auth/register -> Server -> BCrypt(password) -> MongoDB
                                                         |
                                                         v
                                              JWT Token <-

2. Login
   Cliente -> POST /api/auth/login -> Server -> BCrypt(verify) -> MongoDB
                                                         |
                                                         v
                                              JWT Token <-

3. Peticiones Protegidas
   Cliente -> Request + Bearer Token -> JwtAuthFilter -> validate -> Controller
```

## Implementacion Backend

### Archivos principales

| Archivo | Responsabilidad |
| :--- | :--- |
| JwtUtils.java | Generar y validar tokens |
| JwtAuthFilter.java | Filtro para validar requests |
| SecurityConfig.java | Configuracion de Spring Security |
| UserDetailsServiceImpl.java | Carga de usuario para autenticacion |

### Generacion de Token

```java
// JwtUtils.java
public String generateToken(String email) {
    return Jwts.builder()
            .setSubject(email)
            .setIssuedAt(new Date())
            .setExpiration(new Date(System.currentTimeMillis() + jwtExpirationMs))
            .signWith(SignatureAlgorithm.HS512, jwtSecret)
            .compact();
}
```

### Validacion de Token

```java
public boolean validateToken(String token) {
    try {
        Jwts.parser().setSigningKey(jwtSecret).parseClaimsJws(token);
        return true;
    } catch (JwtException e) {
        return false;
    }
}
```

### Filtro de Request

```java
// JwtAuthFilter.java
@Override
protected void doFilterInternal(HttpServletRequest request, ...) {
    String jwt = parseJwt(request);
    if (jwt != null && jwtUtils.validateToken(jwt)) {
        String email = jwtUtils.getEmailFromToken(jwt);
        // Establecer autenticacion en SecurityContext
    }
    filterChain.doFilter(request, response);
}
```

### Configuracion de Seguridad

```java
// SecurityConfig.java
.authorizeRequests()
    .antMatchers("/api/auth/**").permitAll()  // Publico
    .anyRequest().authenticated()               // Protegido
```

## Implementacion Frontend

### Axios Interceptor

```typescript
// lib/axios.ts
api.interceptors.request.use((config) => {
    const token = auth.getToken();
    if (token) {
        config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
});
```

### Manejo de Token

```typescript
// lib/auth.ts
export const auth = {
    getToken: () => localStorage.getItem('task_token'),
    setToken: (token: string) => localStorage.setItem('task_token', token),
    removeToken: () => localStorage.removeItem('task_token'),
};
```

### Login Flow

```typescript
const onSubmit = async (data: LoginForm) => {
    const response = await authApi.login(data.email, data.password);
    const { token, id, name, email } = response.data;
    
    auth.setToken(token);
    auth.setUser({ id, name, email });
    
    router.push('/tasks');
};
```

## Seguridad

### Almacenamiento de Password

- Passwords encriptados con BCrypt
- Nunca se retornan en respuestas API

### Token JWT

- Algoritmo: HS512
- Expiracion: 24 horas (configurable)
- Almacenamiento: localStorage (vulnerable a XSS)

### Mejores practicas para Produccion

1. **Usar HttpOnly cookies** en vez de localStorage
2. **Refresh tokens** para sesiones largas
3. **Rate limiting** en endpoints de login
4. **HTTPS obligatorio** en produccion
5. **Revocacion de tokens** en logout

## Configuracion

### Variables de Entorno

```env
JWT_SECRET=your-super-secret-key-minimum-32-characters-long
JWT_EXPIRATION_MS=86400000
```

### Secret en Kubernetes

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: task-api-secret
type: Opaque
stringData:
  JWT_SECRET: your-secure-secret-here
```

## Verificacion

### Probar endpoint protegido sin token

```bash
curl http://localhost:8080/api/tasks
# {"status":401,"error":"Unauthorized","message":"Full authentication is required..."}
```

### Con token valido

```bash
TOKEN=$(curl -s -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","password":"123456"}' | jq -r '.token')

curl http://localhost:8080/api/tasks -H "Authorization: Bearer $TOKEN"
```
