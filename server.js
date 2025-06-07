const express = require('express');
const fs = require('fs');
const path = require('path');
const app = express();

// 静的ファイル（index.html, images/ など）を配信
app.use(express.static(__dirname));

// 画像ファイル一覧API
app.get('/api/images', (req, res) => {
  const dir = path.join(__dirname, 'images');
  fs.readdir(dir, (err, files) => {
    if (err) return res.status(500).json({ error: err.toString() });
    const jpgs = files.filter((f) => f.endsWith('.jpg')).sort();
    res.json(jpgs);
  });
});

// サーバー終了API
app.post('/shutdown', (req, res) => {
  res.send('シャットダウンします');
  process.exit(0);
});

const PORT = 3000;
app.listen(PORT, () => {
  console.log(`http://localhost:${PORT} で index.html が見られます`);
});
