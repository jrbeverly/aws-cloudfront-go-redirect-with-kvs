import cf from 'cloudfront';

const kvsHandle = cf.kvs("${kvs_id}");

async function handler(event) {
    const key = event.request.uri.split('/').find(s => s !== '');

    if (!key) {
        return { statusCode: 404, statusDescription: 'Not Found' };
    }

    try {
        const url = await kvsHandle.get(key);
        return {
            statusCode: 302,
            statusDescription: 'Found',
            headers: { location: { value: url } },
        };
    } catch (err) {
        return { statusCode: 404, statusDescription: 'Not Found' };
    }
}
