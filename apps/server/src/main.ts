import { NestFactory } from '@nestjs/core'
import { AppModule } from './app.module'
import { configs } from './configs'

async function bootstrap() {
  const app = await NestFactory.create(AppModule)
  app.enableCors({ origin: configs.app.corsOrigin })
  await app.listen(configs.app.port)
}
void bootstrap()
