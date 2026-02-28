import NextAuth from 'next-auth';
import Google from 'next-auth/providers/google';

const ALLOWED_EMAILS = process.env.ALLOWED_ADMIN_EMAILS?.split(',') || ['lnxelnope@gmail.com'];

export const { handlers, signIn, signOut, auth } = NextAuth({
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
