const express = require('express');
const bodyParser = require('body-parser');
const PublicStorage = require('./storage/publicStorage');

const app = express();
const port = process.env.PORT || 3000;

// Middleware
app.use(bodyParser.json());

// Initialize PublicStorage
const publicStorage = new PublicStorage();

// Routes
app.post('/upload', async (req, res) => {
    try {
        const file = req.body.file;
        const result = await publicStorage.uploadFile(file);
        res.status(200).json({ message: 'File uploaded successfully', data: result });
    } catch (error) {
        res.status(500).json({ message: 'Error uploading file', error: error.message });
    }
});

app.get('/download/:fileId', async (req, res) => {
    try {
        const fileId = req.params.fileId;
        const file = await publicStorage.downloadFile(fileId);
        res.status(200).send(file);
    } catch (error) {
        res.status(500).json({ message: 'Error downloading file', error: error.message });
    }
});

app.delete('/delete/:fileId', async (req, res) => {
    try {
        const fileId = req.params.fileId;
        await publicStorage.deleteFile(fileId);
        res.status(200).json({ message: 'File deleted successfully' });
    } catch (error) {
        res.status(500).json({ message: 'Error deleting file', error: error.message });
    }
});

// Start the server
app.listen(port, () => {
    console.log(`Server is running on http://localhost:${port}`);
});