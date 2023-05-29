from flask import Flask, render_template
import requests
from bs4 import BeautifulSoup

app = Flask(__name__)

@app.route("/")
def home():
    # Scrape the titles
    url = 'http://books.toscrape.com/'
    response = requests.get(url)
    soup = BeautifulSoup(response.text, 'html.parser')
    titles = [book['title'] for book in soup.find_all('a', title=True)]

    # Function to get ISBN from Open Library
    def get_isbn(title):
        response = requests.get(f'https://openlibrary.org/search.json?q={title}')
        data = response.json()
        if 'docs' in data and len(data['docs']) > 0:
            isbn = data['docs'][0].get('isbn')
            return isbn[0] if isbn else None
        else:
            return None

    # Get ISBNs and construct Amazon links
    books = [{'title': title, 'isbn': get_isbn(title)} for title in titles]
    for book in books:
        if book['isbn']:
            book['amazon_link'] = f"https://www.amazon.com/s?k={book['isbn']}"

    return render_template('index.html', books=books)

if __name__ == "__main__":
    app.run(debug=True)
