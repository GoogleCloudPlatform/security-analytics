function embeddingModelOutputColumns(model_name) {
    var columns = ['ml_generate_embedding_result'];
    // Strip out any version number from the model name
    switch (model_name.split('@')[0]) {
        case 'multimodalembedding':
            columns.push('ml_generate_embedding_status');
            break;
        case 'textembedding-gecko':
        case 'textembedding-gecko-multilingual':
            columns.push('ml_generate_embedding_status', 'ml_generate_embedding_statistics');
            break;
    }
    return columns;
}

module.exports = {
    embeddingModelOutputColumns
};