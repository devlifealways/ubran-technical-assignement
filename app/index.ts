import * as express from 'express';
import 'express-async-errors';

const SERVER_PORT = process.env.PORT || 3000;
const environment = process.env.NODE_ENV || "development";
const isDev = environment === "development";

const app = express();

app.get('*', (req: express.Request, res: express.Response) => {
  const response = {
    hostname: req.hostname,
    uptime: process.uptime(),
    podname: process.env.HOSTNAME,
  };

  res.status(200).send(response);
});

app.listen(SERVER_PORT, () => {
  console.log(`listening on ${SERVER_PORT} 🚀`);
});