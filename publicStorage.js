class PublicStorage {
    constructor(storageService) {
        this.storageService = storageService; // Initialize with a specific storage service (e.g., AWS S3, Google Cloud Storage)
    }

    async uploadFile(file) {
        try {
            const response = await this.storageService.upload(file);
            return response; // Return the response from the storage service
        } catch (error) {
            throw new Error(`File upload failed: ${error.message}`);
        }
    }

    async downloadFile(fileName) {
        try {
            const file = await this.storageService.download(fileName);
            return file; // Return the downloaded file
        } catch (error) {
            throw new Error(`File download failed: ${error.message}`);
        }
    }

    async deleteFile(fileName) {
        try {
            const response = await this.storageService.delete(fileName);
            return response; // Return the response from the storage service
        } catch (error) {
            throw new Error(`File deletion failed: ${error.message}`);
        }
    }
}

export default PublicStorage;