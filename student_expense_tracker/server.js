import app from './app.js';
import open from 'open';

const PORT = 3000;
const HOST = '0.0.0.0';

app.listen(PORT, HOST, () => {
  const url = `http://localhost:${PORT}`;
  console.log(`Server is running at ${url}`);
  open(url);
});