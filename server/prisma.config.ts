import 'dotenv/config';
import { defineConfig } from 'prisma/config';
import { PrismaPg } from '@prisma/adapter-pg';

export default defineConfig({
  datasource: {
    url: process.env.DATABASE_URL,
  },
  migrations: {
    seed: 'ts-node prisma/seed.ts',
  },
  migrate: {
    adapter(env: Record<string, string | undefined>) {
      return new PrismaPg({ connectionString: env['DATABASE_URL']! });
    },
  },
});
