from flask import Flask, render_template
import requests
from bs4 import BeautifulSoup

app = Flask(__name__)

@app.route('/')
def home():
    response = requests.get('http://books.toscrape.com/')
    soup = BeautifulSoup(response.content, 'html.parser')
    books = soup.find_all('article', class_='product_pod')

    book_data = []
    for book in books:
        title = book.h3.a.get('title')
        price = book.find('p', class_='price_color').text
        rating_class = book.find('p', class_='star-rating').get('class')
        rating = [x for x in rating_class if x != 'star-rating'][0]
        book_data.append({'title': title, 'price': price, 'rating': rating})

    return render_template('index.html', books=book_data)

if __name__ == "__main__":
    app.run(debug=True)
