import { DevOauthHint } from './dev-oauth-hint';
import { LoginClient } from './login-client';

export default function LoginPage() {
  return (
    <div className="flex min-h-screen flex-col">
      <DevOauthHint />
      <LoginClient />
    </div>
  );
}
