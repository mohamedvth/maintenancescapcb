// src/utils/index.js

export const validateFileType = (file, allowedTypes) => {
    const fileType = file.type;
    return allowedTypes.includes(fileType);
};

export const handleError = (error) => {
    console.error('An error occurred:', error);
    return { success: false, message: error.message };
};