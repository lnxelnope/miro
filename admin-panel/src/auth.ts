import NextAuth from 'next-auth';
import Google from 'next-auth/providers/google';

const ALLOWED_EMAILS = process.env.ALLOWED_ADMIN_EMAILS?.split(',') || ['lnxelnope@gmail.com'];

/** Auth.js requires a secret; set AUTH_SECRET or NEXTAUTH_SECRET in .env.local (see .env.example). */
const authSecret =
  process.env.AUTH_SECRET ??
  process.env.NEXTAUTH_SECRET ??
  (process.env.NODE_ENV === 'development'
    ? 'local-dev-auth-secret-min-32-chars-miro-admin-do-not-use-in-prod'
    : undefined);

export const { handlers, signIn, signOut, auth } = NextAuth({
  secret: authSecret,
  providers: [
    Google({
      clientId: process.env.GOOGLE_CLIENT_ID as string,
      clientSecret: process.env.GOOGLE_CLIENT_SECRET as string,
    }),
  ],
  callbacks: {
    async signIn({ user }) {
      // เช็คว่า email อยู่ใน whitelist
      if (user.email && ALLOWED_EMAILS.includes(user.email)) {
        return true;
      }
      return false;
    },
    async session({ session, token }) {
      if (session.user) {
        session.user.id = token.sub as string;
      }
      return session;
    },
  },
  pages: {
    signIn: '/login',
  },
  trustHost: true,
});
