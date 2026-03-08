import { z } from 'zod'

export enum NodeEnv {
  Development = 'development',
  Production = 'production',
}

export enum LogLevel {
  Fatal = 'fatal',
  Error = 'error',
  Warn = 'warn',
  Info = 'info',
  Debug = 'debug',
  Trace = 'trace',
}

const envSchema = z.object({
  NODE_ENV: z.nativeEnum(NodeEnv),
  PORT: z.coerce.number(),
  LOG_LEVEL: z.nativeEnum(LogLevel),
  CORS_ORIGIN: z.string(),
  REDIS_HOST: z.string(),
  REDIS_PORT: z.coerce.number(),
})

const result = envSchema.safeParse(process.env)

if (!result.success) {
  const formatted = result.error.flatten().fieldErrors
  throw new Error(`Invalid environment variables:\n${JSON.stringify(formatted, null, 2)}`)
}

export const configs = {
  app: {
    nodeEnv: result.data.NODE_ENV,
    port: result.data.PORT,
    logLevel: result.data.LOG_LEVEL,
    corsOrigin: result.data.CORS_ORIGIN,
  },
  redis: {
    host: result.data.REDIS_HOST,
    port: result.data.REDIS_PORT,
  },
}
