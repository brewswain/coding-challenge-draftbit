import 'dotenv/config';
import { Client } from 'pg';
import { backOff } from 'exponential-backoff';
import express from 'express';
import waitOn from 'wait-on';
import onExit from 'signal-exit';
import cors from 'cors';

// Add your routes here
const setupApp = (client: Client): express.Application => {
   const app: express.Application = express();

   app.use(cors());

   app.use(express.json());

   app.get('/examples', async (_req, res) => {
      const { rows } = await client.query(`SELECT * FROM example_table`);
      res.json(rows);
   });

   app.get('/dimensions', async (_req, res) => {
      const { rows } = await client.query(`SELECT * FROM dimensions LIMIT 1`);
      res.json(rows[0]);
   });

   app.patch('/dimensions', async (req, res) => {
      const dimensions = req.body;

      const { rows } = await client.query(
         // `UPDATE dimensions SET ${dimensions.target_column}=${dimensions.updated_column}  RETURNING *`
         `UPDATE dimensions SET ${dimensions.target_column}=$1  RETURNING *`,
         [dimensions.updated_column]
      );
      res.json(rows[0]);
   });

   return app;
};

// Waits for the database to start and connects
const connect = async (): Promise<Client> => {
   console.log('Connecting');
   const resource = `tcp:${process.env.PGHOST}:${process.env.PGPORT}`;
   console.log(`Waiting for ${resource}`);
   await waitOn({ resources: [resource] });
   console.log('Initializing client');
   const client = new Client();

   await client.connect();
   console.log('Connected to database');

   // Ensure the client disconnects on exit
   onExit(async () => {
      console.log('onExit: closing client');
      await client.end();
   });

   return client;
};

const main = async () => {
   const client = await connect();
   const app = setupApp(client);

   if (!process.env.SERVER_PORT) {
      throw new Error('SERVER_PORT is not defined');
   }

   const port = parseInt(process.env.SERVER_PORT);
   app.listen(port, () => {
      console.log(
         `Draftbit Coding Challenge is running at http://localhost:${port}/`
      );
   });
};

main();
