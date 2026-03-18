const express = require("express");
const fs = require("fs")
const path = require("path")
const app = express();
const port = 3000;

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// imagenes portada -> path ../public
app.use('/images', express.static('public'))


const SONGS_PATH = path.join(__dirname, "songs.json");

function loadSongs() {
    return JSON.parse(fs.readFileSync(SONGS_PATH, "utf-8"));

}

function saveSongs(songs) {
    fs.writeFileSync(SONGS_PATH, JSON.stringify(songs, null, 2));
}


app.get('/songs', (req, res) => {
    const songs = loadSongs();
    res.json(songs);
});

app.get('/', getHello)
    async function getHello (req, res) {
    res.send(`Holaa prueba sever todo OK`);
}

app.put('/songs/:id/favorite', (req, res) => {
    const songId = Number(req.params.id);
    console.log(req.body);
    const { favorite } = req.body

    let songs = loadSongs();

    const index = songs.findIndex(s => s.id === songId);

    songs[index].favorite = Boolean(favorite);

    saveSongs(songs);

    res.json(songs[index]);
})

// Aserver on
const httpServer = app.listen(port, appListen)
function appListen () {
    console.log(`Example app listening on: http://0.0.0.0:${port}`)
}


// apaga server
process.on('SIGTERM', shutDown);
process.on('SIGINT', shutDown);
function shutDown() {
    console.log('Received kill signal, shutting down gracefully');
    httpServer.close()
    process.exit(0);
}