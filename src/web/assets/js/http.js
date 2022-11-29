

class FHIRSearchParams {
    _count;
    _sort;
    page;
    queryId;

    getSearchExpression() {
        let filter = [];
        if (this._count) {
            filter.push(`_count=${this._count}`);
        }
        if (this._sort) {
            filter.push(`_sort=${this._sort}`);
        }
        if (this.page) {
            filter.push(`page=${this.page}`);
        }
        if (this.queryId) {
            filter.push(`queryId=${this.queryId}`);
        }
        return filter.join("&");
    }
}

const httpGet = (url) => {
    return fetch(url).then(response => {
        if (!response.ok) {
            return Promise.reject(response);
        }
        return response;
    });
}

const httpPost = (url, data) => {
    return fetch(url, {
        method: "POST",
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify(data),
    }).then(response => {
        if (!response.ok) {
            return Promise.reject(response);
        }
        return response;
    });
}

const httpPut = (url, data) => {
    return fetch(url, {
        method: "PUT",
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify(data),
    }).then(response => {
        if (!response.ok) {
            return Promise.reject(response);
        }
        return response;
    });
}

const httpDelete = (url) => {
    return fetch(url, {
        method: "DELETE"
    }).then(response => {
        if (!response.ok) {
            return Promise.reject(response);
        }
        return response;
    });
}