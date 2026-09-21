#!/usr/bin/env node
// Asigna las imágenes descargadas a cada subasta activa:
//   images = ['/images/auctions/<slug>.jpg', '/images/auctions/<slug>-2.jpg', '/images/auctions/<slug>-3.jpg']
import 'dotenv/config';
import pg from 'pg';

const { Client } = pg;
const client = new Client({
  host: process.env.DB_HOST ?? 'localhost',
  port: parseInt(process.env.DB_PORT ?? '5432', 10),
  user: process.env.DB_USER ?? 'postgres',
  password: process.env.DB_PASSWORD ?? 'postgres',
  database: process.env.DB_NAME ?? 'subastas',
});

function slugify(title) {
  return title
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '');
}

await client.connect();
try {
  const { rows } = await client.query(
    "SELECT id, title FROM auctions WHERE status = 'active'",
  );
  let updated = 0;
  for (const row of rows) {
    const slug = slugify(row.title);
    const paths = [
      `/images/auctions/${slug}.jpg`,
      `/images/auctions/${slug}-2.jpg`,
      `/images/auctions/${slug}-3.jpg`,
    ];
    const res = await client.query(
      "UPDATE auctions SET images = $1::jsonb WHERE id = $2",
      [JSON.stringify(paths), row.id],
    );
    updated += res.rowCount ?? 0;
  }
  console.log(`${updated}/${rows.length} subastas actualizadas con 3 imágenes.`);
} finally {
  await client.end();
}