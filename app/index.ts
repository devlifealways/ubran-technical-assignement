import * as express from 'express';
import 'express-async-errors';
import * as client from 'prom-client';

const SERVER_PORT = process.env.PORT || 3000;
const environment = process.env.NODE_ENV || "development";
const isDev = environment === "development";

const app = express();
const registry = new client.Registry();
const counter = new client.Counter({
  name: 'visitors',
  help: 'Number of visitors',
  registers: [registry],
});

registry.setDefaultLabels({
  application:'urban-technical-test',
  env: environment
});

app.get("/", (req: express.Request, res: express.Response) => {
  const response = {
    hostname: req.hostname,
    uptime: process.uptime(),
    podname: process.env.HOSTNAME,
  };

  if (isDev){
    console.log(`/ called with these headers ${JSON.stringify(req.headers)}`);
  }

  counter.inc();
  res.status(200).send(response);
});

app.get("/metrics", async (req: express.Request, res : express.Response) => {

  if (isDev){
    console.log(`/metrics called with these headers ${JSON.stringify(req.headers)}`);
  }

  res.setHeader("Content-Type", client.register.contentType);
  res.end(await registry.metrics());
});

app.listen(SERVER_PORT, () => {
  console.log(`listening on ${SERVER_PORT} 🚀`);
});