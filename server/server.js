// API local sin dependencias. Ejecutar: node server/server.js
const http = require('http');

const productos = [
  {
    id: 1,
    nombre: 'Laptop Lenovo',
    categoria: 'Computadoras',
    precio: 2499.9,
    disponibilidad: 5,
    descripcion: 'Laptop Lenovo con procesador Intel Core i5 y 8GB de RAM.',
    imagePath: 'assets/image/lenovo.jpg',
  },
  {
    id: 2,
    nombre: 'Mouse inalámbrico',
    categoria: 'Accesorios',
    precio: 59.9,
    disponibilidad: 20,
    descripcion: 'Mouse inalámbrico ergonómico con receptor USB.',
    imagePath: 'assets/image/mouse.jpg',
  },
  {
    id: 3,
    nombre: 'Teclado mecánico',
    categoria: 'Accesorios',
    precio: 129.9,
    disponibilidad: 12,
    descripcion: 'Teclado mecánico retroiluminado.',
    imagePath: 'assets/image/teclado.jpg',
  },
];

const server = http.createServer((req, res) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Content-Type', 'application/json; charset=utf-8');

  if (req.method === 'GET' && req.url === '/products') {
    res.end(JSON.stringify(productos));
    return;
  }

  res.statusCode = 404;
  res.end(JSON.stringify({ error: 'No encontrado' }));
});

server.listen(3000, () => {
  console.log('API en http://localhost:3000/products');
});
