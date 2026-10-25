// API local sin dependencias. Ejecutar: node server/server.js
const http = require('http');

const productos = [
  {
    id: 1,
    nombre: 'caña de pescar',
    categoria: 'aire libre',
    precio: 200000 ,
    disponibilidad: 5,
    descripcion: 'Caña telescópica de fibra de vidrio de 2,1 m, liviana y fácil de transportar. Incluye carrete y sirve para principiantes en río o lago.',
    imagePath: 'assets/image/caña_pescar.jpg',
  },
  {
    id: 2,
    nombre: 'Binoculares',
    categoria: 'aire libre',
    precio: 180000,
    disponibilidad: 20,
    descripcion: 'Binoculares 10x42 con lentes de buena nitidez y agarre antideslizante. Perfectos para observar aves, paisajes o ir de camping.',
    imagePath: 'assets/image/binoculares.jpg',
  },
  {
    id: 3,
    nombre: 'Cubo rubick megamix',
    categoria: 'juegos',
    precio: 50000,
    disponibilidad: 12,
    descripcion: 'Cubo mágico megamix con giro suave y colores vivos. Ejercita la lógica y la memoria, ideal para aprender a resolverlo o competir contra el reloj.',
    imagePath: 'assets/image/Cubo_megamix.jpg',
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
