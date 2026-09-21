#!/usr/bin/env node
// Descarga hasta 3 imágenes por cada vehículo en las subastas activas y las
// guarda en public/images/auctions/:
//   <slug>.jpg     -> imagen principal (Wikipedia)
//   <slug>-2.jpg   -> 2ª imagen (fotos del artículo, generación cercana)
//   <slug>-3.jpg   -> 3ª imagen
// Fuente: página de Wikipedia (imagen principal + imágenes del artículo) con
// fallback a Commons search.
import { mkdir, writeFile, access, readdir } from 'node:fs/promises';
import { dirname, join } from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';

const API = process.env.API_URL ?? 'http://localhost:3000';
const OUT_DIR = join(
  dirname(fileURLToPath(import.meta.url)),
  '..',
  'public',
  'images',
  'auctions',
);

const MAX_PER_AUCTION = 3;

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

export const WIKI = {
  'Toyota Corolla': 'Toyota Corolla',
  'Toyota Camry': 'Toyota Camry',
  'Honda Civic': 'Honda Civic',
  'Honda Accord': 'Honda Accord',
  'Nissan Altima': 'Nissan Altima',
  'Nissan Sentra': 'Nissan Sentra',
  'Hyundai Elantra': 'Hyundai Elantra',
  'Kia Forte': 'Kia Forte',
  'Ford F-150': 'Ford F-150',
  'Chevrolet Silverado': 'Chevrolet Silverado',
  'GMC Sierra': 'GMC Sierra',
  'Ram 1500': 'Ram pickup',
  'Toyota RAV4': 'Toyota RAV4',
  'Honda CR-V': 'Honda CR-V',
  'Chevrolet Equinox': 'Chevrolet Equinox',
  'Ford Explorer': 'Ford Explorer',
  'Jeep Grand Cherokee': 'Jeep Grand Cherokee',
  'Jeep Wrangler': 'Jeep Wrangler',
  'Tesla Model 3': 'Tesla Model 3',
  'Tesla Model Y': 'Tesla Model Y',
  'Ford Mustang': 'Ford Mustang',
  'Chevrolet Camaro': 'Chevrolet Camaro',
};

export function slugify(title) {
  return title
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '');
}

export function findKey(title) {
  const norm = (s) => s.toLowerCase().replace(/[-\s]+/g, '');
  const t = norm(title);
  return Object.keys(WIKI).find((k) => t.includes(norm(k)));
}

export function findYear(title) {
  const m = title.match(/\b(19|20)\d{2}\b/);
  return m ? parseInt(m[0], 10) : null;
}

// Sobrescrituras curadas para vehículos donde la selección automática elegía
// fotos de otra generación/marca. Key = slug del vehículo.
export const MAIN_OVERRIDES = {
  'chevrolet-silverado-1500-lt-2021':
    'File:2019 Chevrolet Silverado 1500 Crew Cab LT (front), 10.20.19.jpg',
  'gmc-sierra-1500-sle-2021':
    'File:2021 GMC Sierra 1500 AT4, Front Left, 03-26-2021.jpg',
  'ford-mustang-gt-2020': 'File:2020 Ford Mustang GT.jpg',
};

export const EXTRA_OVERRIDES = {
  'honda-accord-sport-2021': [
    'File:2021 Honda Accord Sport 2.0T, front right, 09-06-2022.jpg',
    'File:2021 Honda Accord Sport 2.0T, rear right, 09-06-2022.jpg',
  ],
  'honda-cr-v-ex-2022': [
    'File:2021 Honda CR-V SE 4x2 CVT.jpg',
    'File:2021 Honda CR-V 1.5T Prestige (rear).jpg',
  ],
  'hyundai-elantra-sel-2022': [
    'File:Hyundai Elantra Langdong Facelift Shishi 01 2022-05-20.jpg',
    'File:Hyundai Elantra Langdong Facelift Shishi 02 2022-05-20.jpg',
  ],
  'nissan-altima-sv-2022': [
    'File:2022 Nissan Altima SV, front left, 05-03-2023.jpg',
    'File:Nissan Altima L34 Shishi 02 2022-09-20.jpg',
  ],
  'nissan-sentra-sr-2022': [
    'File:Nissan Sentra 2.0 Exclusive 2022.jpg',
    'File:Nissan Sentra SR (20425523203).jpg',
  ],
  'ram-1500-big-horn-2021': [
    'File:2021 Ram 1500 Hemi 5.7.jpg',
    'File:Ram 1500 5.7 Hemi Laramie 2021.jpg',
  ],
  'toyota-rav4-xle-2022': [
    'File:Toyota Rav4 XLE Hybrid 2022.jpg',
    'File:Toyota RAV4 2.5L XLE HEV 2022.jpg',
  ],
  'gmc-sierra-1500-sle-2021': [
    'File:GMC Sierra 1500 Denali (2021) (55258181429).jpg',
    'File:2021 GMC Sierra 1500 Crew Cab Short Bed Elevation 4WD X31 Off-Road Package in Summit White, front left, 2024-05-27.jpg',
  ],
  'chevrolet-silverado-1500-lt-2021': [
    'File:2020 Chevrolet Silverado 1500 Custom.jpg',
    'File:Chevrolet Silverado 1500 Z71 (GMTK2XX) Washington DC Metro Area, USA.jpg',
  ],
  'ford-f-150-xlt-4x4-2021': [
    'File:2021 Ford F-150 SuperCrew, front 4.28.21.jpg',
    "File:'21 Ford F-150 XLT Crew Cab.jpg",
  ],
  'ford-mustang-gt-2020': [
    'File:2020 Ford Mustang GT, Kingsville, Ontario, 2025-06-29.jpg',
    'File:2020 Ford Mustang 5.0 GT V8 in Shadow Black, rear right, 06-23-2024.jpg',
  ],
};

const headers = { 'User-Agent': 'SubastasDev/1.0 (contacto: dev@subastas.local)' };

async function fetchRetry(url, attempts = 3) {
  for (let i = 0; i < attempts; i++) {
    const res = await fetch(url, { headers });
    if (res.status === 429) {
      const wait = 3000 * (i + 1);
      console.log(`    rate-limited, esperando ${wait / 1000}s...`);
      await sleep(wait);
      continue;
    }
    return res;
  }
  return null;
}

export async function wikiSummary(article) {
  const url = `https://en.wikipedia.org/api/rest_v1/page/summary/${encodeURIComponent(article)}`;
  const res = await fetchRetry(url);
  if (!res || !res.ok) return null;
  const data = await res.json();
  return data?.originalimage?.source ?? data?.thumbnail?.source ?? null;
}

async function commonsSearch(term, limit = 1) {
  const url =
    'https://commons.wikimedia.org/w/api.php?action=query&format=json' +
    '&generator=search&gsrsearch=' +
    encodeURIComponent(term) +
    '&gsrnamespace=6&gsrlimit=10&prop=imageinfo&iiprop=url' +
    '&iiurlwidth=1200';
  const res = await fetchRetry(url);
  if (!res || !res.ok) return [];
  const data = await res.json();
  const pages = data?.query?.pages;
  if (!pages) return [];
  const candidates = Object.values(pages)
    .map((p) => p?.imageinfo?.[0]?.thumburl)
    .filter(Boolean);
  return candidates.slice(0, limit);
}

// Basename normalizado de una URL de upload (quita el prefijo de tamaño de thumb).
function baseName(url) {
  return (url.split('/').pop() || '').replace(/^\d+px-/i, '');
}

export async function fileThumbUrl(title) {
  const url =
    'https://en.wikipedia.org/w/api.php?action=query&format=json&titles=' +
    encodeURIComponent(title) +
    '&prop=imageinfo&iiprop=url&iiurlwidth=1200';
  const res = await fetchRetry(url);
  if (!res || !res.ok) return null;
  const data = await res.json();
  const pages = data?.query?.pages ?? {};
  for (const p of Object.values(pages)) {
    const info = p?.imageinfo?.[0];
    if (info?.thumburl) return info.thumburl;
    if (info?.url) return info.url;
  }
  return null;
}

// Lista de thumb URLs de imágenes usadas en el artículo de Wikipedia del modelo.
// Si `nearYear` no es null, filtra a la generación cercana al año del vehículo.
async function articleFiles(article, nearYear) {
  const listUrl =
    'https://en.wikipedia.org/w/api.php?action=query&format=json' +
    '&prop=images&titles=' +
    encodeURIComponent(article) +
    '&imlimit=200';
  const res = await fetchRetry(listUrl);
  if (!res || !res.ok) return [];
  const data = await res.json();
  const pages = data?.query?.pages ?? {};
  const files = [];
  for (const page of Object.values(pages)) {
    for (const image of page?.images ?? []) {
      if (/\.(jpe?g|png)$/i.test(image.title)) files.push(image.title);
    }
  }
  if (nearYear != null && nearYear.length > 0) {
    const filtered = files.filter((t) => nearYear.some((y) => t.includes(y)));
    if (filtered.length > 0) {
      files.length = 0;
      files.push(...filtered);
    }
  }
  const unique = [...new Set(files)];

  // Prioriza ángulos variados: trasera, frontal, interior.
  const score = (t) => {
    const lower = t.toLowerCase();
    let s = 0;
    if (lower.includes('rear')) s += 90;
    if (lower.includes('front')) s += 60;
    if (lower.includes('interior')) s += 40;
    return s;
  };
  unique.sort((a, b) => score(b) - score(a));

  const urls = [];
  for (const title of unique.slice(0, 6)) {
    const thumb = await fileThumbUrl(title);
    if (thumb) urls.push(thumb);
    await sleep(300);
  }
  return urls;
}

// Devuelve URLs de imágenes adicionales para el vehículo, en orden de calidad:
// 1) generación cercana del artículo, 2) Commons search "<model> <año>",
// 3) último recurso: cualquier imagen del artículo.
export async function articleImages(article, key, year, mainUrl) {
  const nearYear =
    year == null ? null : [year - 2, year - 1, year, year + 1, year + 2].map(String);
  const mainBase = baseName(mainUrl ?? '');
  const notMain = (u) => baseName(u) !== mainBase;
  const wanted = MAX_PER_AUCTION - 1;

  const urls = [];
  for (const u of (await articleFiles(article, nearYear))) {
    if (urls.length >= wanted) break;
    if (notMain(u)) urls.push(u);
  }

  if (urls.length < wanted && year != null) {
    const common = await commonsSearch(`${key} ${year}`, wanted - urls.length);
    for (const u of common) {
      if (urls.length >= wanted) break;
      if (notMain(u)) urls.push(u);
    }
  }

  if (urls.length < wanted) {
    for (const u of (await articleFiles(article, null))) {
      if (urls.length >= wanted) break;
      if (notMain(u)) urls.push(u);
    }
  }

  return urls;
}

async function download(url, dest) {
  const res = await fetchRetry(url);
  if (!res || !res.ok) throw new Error(`HTTP ${res?.status} para ${url}`);
  const buf = Buffer.from(await res.arrayBuffer());
  await writeFile(dest, buf);
  return buf.length;
}

export async function ensureDownload(url, dest) {
  try {
    await access(dest);
    return { ok: true, skipped: true };
  } catch {
    // no existe aún -> descargar
  }
  const bytes = await download(url, dest);
  return { ok: true, bytes, src: url };
}

async function main() {
  const offline = process.argv.includes('--offline');
  let auctions;
  if (offline) {
    // Sin API/BD: usa los archivos ya descargados en OUT_DIR como referencia.
    const files = (await readdir(OUT_DIR)).filter(
      (f) => /\.jpe?g$/i.test(f) && !/-\d\.jpe?g$/i.test(f),
    );
    auctions = files.map((f) => ({
      title: f
        .replace(/\.jpe?g$/i, '')
        .split('-')
        .map((w) => (w ? w[0].toUpperCase() + w.slice(1) : w))
        .join(' '),
    }));
    console.log(`Modo offline: ${auctions.length} vehículos detectados.`);
  } else {
    const res = await fetch(`${API}/auctions`);
    auctions = await res.json();
  }
  await mkdir(OUT_DIR, { recursive: true });

  const results = [];
  for (const auction of auctions) {
    const key = findKey(auction.title);
    if (!key) {
      results.push({ title: auction.title, ok: false, reason: 'sin mapeo wiki' });
      continue;
    }
    const slug = slugify(auction.title);
    const year = findYear(auction.title);
    const dests = [
      join(OUT_DIR, `${slug}.jpg`),
      join(OUT_DIR, `${slug}-2.jpg`),
      join(OUT_DIR, `${slug}-3.jpg`),
    ];

    // Imagen principal (override curado o automática de Wikipedia).
    let mainSrc = null;
    if (MAIN_OVERRIDES[slug]) {
      mainSrc = await fileThumbUrl(MAIN_OVERRIDES[slug]);
    }
    if (!mainSrc) {
      mainSrc = await wikiSummary(WIKI[key]);
    }
    if (!mainSrc) {
      console.log(`  -> fallback Commons search para "${key}"`);
      mainSrc = (await commonsSearch(key, 1))[0] ?? null;
    }
    if (!mainSrc) {
      results.push({ title: auction.title, ok: false, reason: 'sin imagen principal' });
      continue;
    }

    const downloaded = [];
    try {
      const r = await ensureDownload(mainSrc, dests[0]);
      downloaded.push({ index: 0, ...r });
    } catch (err) {
      downloaded.push({ index: 0, ok: false, reason: err.message });
    }

    // Imágenes adicionales (override curado o selección automática).
    let extras = [];
    if (EXTRA_OVERRIDES[slug]) {
      for (const title of EXTRA_OVERRIDES[slug]) {
        const url = await fileThumbUrl(title);
        if (url) extras.push(url);
        await sleep(300);
      }
    } else {
      extras = await articleImages(WIKI[key], key, year, mainSrc);
    }
    for (let i = 0; i < extras.length && downloaded.length < MAX_PER_AUCTION; i++) {
      const idx = downloaded.length;
      try {
        const r = await ensureDownload(extras[i], dests[idx]);
        downloaded.push({ index: idx, ...r });
      } catch (err) {
        downloaded.push({ index: idx, ok: false, reason: err.message });
      }
      await sleep(400);
    }

    const okDownloads = downloaded.filter((d) => d.ok);
    if (okDownloads.length === 0) {
      results.push({ title: auction.title, ok: false, reason: downloaded[0]?.reason ?? 'descarga fallida' });
      continue;
    }
    results.push({
      title: auction.title,
      ok: true,
      count: okDownloads.length,
      srcs: okDownloads.map((d) => d.src).filter(Boolean),
    });
    await sleep(1200); // respeto al API
  }

  for (const r of results) {
    console.log(
      r.ok
        ? `OK(${r.count}) ${r.title}\n      ${(r.srcs ?? []).join('\n      ')}`
        : `FAIL ${r.title}: ${r.reason}`,
    );
  }
  const ok = results.filter((r) => r.ok).length;
  console.log(`\n${ok}/${results.length} subastas con imágenes en ${OUT_DIR}`);
}

// Solo se ejecuta main() cuando se invoca directamente (permite importar las
// funciones auxiliares desde otros scripts).
if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  main().catch((err) => {
    console.error(err);
    process.exit(1);
  });
}