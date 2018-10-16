"""
Shopping Demo Mycroft Skill.
"""
import random
import time
import requests
import base64
import string
from adapt.intent import IntentBuilder
from os.path import join, dirname
from string import Template
from mycroft.skills.core import MycroftSkill, intent_handler
from mycroft.skills.context import *
from mycroft.util import read_stripped_lines
from mycroft.util.log import getLogger
from mycroft.messagebus.message import Message

__author__ = 'aix'

LOGGER = getLogger(__name__)
productBlob = ""
productObject = {}
productAddList = []
priceOfItems = []
shopPage = ""
checkoutPrice = ""

class ShoppingDemoSkill(MycroftSkill):
    def __init__(self):
        """
        Shopping Demo Skill Class.
        """    
        super(ShoppingDemoSkill, self).__init__(name="ShoppingDemoSkill")

    def initialize(self):
        try:
            # Register handlers for messagebus events
            self.add_event('aiix.shopping-demo.add_product', self.handle_add_product_intent)
            self.add_event('aiix.shopping-demo.remove_product', self.handle_remove_product_intent)
            self.add_event('aiix.shopping-demo.view_cart', self.handle_viewcart_intent)
            self.add_event('aiix.shopping-demo.clear_cart', self.handle_clearcart_intent)
            self.add_event('aiix.shopping-demo.checkout', self.handle_checkout)
            self.add_event('aiix.shopping-demo.get_product_count', self.get_shop_cart_count)
            self.add_event('aiix.shopping-demo.process_payment', self.complete_payment)
        
        except:
            pass

    @intent_handler(IntentBuilder("SearchProduct").require("SearchProductKeyword").build())
    def handle_search_product_intent(self, message):
        """
        Search Product
        """    
        utterance = message.data.get('utterance').lower()
        utterance = utterance.replace(message.data.get('SearchProductKeyword'), '')
        searchString = utterance
        eapi = "MGE5YzQwNDFlZjJiNDdhYTk4NmFlZGZiZTgxODNhYmY="
        api_key = base64.b64decode(eapi)
        headers = {'Ocp-Apim-Subscription-Key': api_key}
        product = searchString
        offset = "0"
        limit = "10"
        url = "https://dev.tescolabs.com/grocery/products/?query={0}&offset={1}&limit={2}".format(product, offset, limit)
        response = requests.get(url, headers=headers)
        result_search = response.json()
        global productBlob
        productBlob = result_search
        self.enclosure.bus.emit(Message("metadata", {"type": "shopping-demo", "dataBlob": productBlob['uk']['ghs']['products'], "itemCartCount": len(productAddList)}))
        
    @intent_handler(IntentBuilder("AddProduct").require("AddProductKeyword").build())
    def handle_add_product_intent(self, message):
        """
        Add Product
        """
        try:
            utterance = message.data.get('utterance').lower()
            utterance = utterance.replace(message.data.get('AddProductKeyword'), '')
            productTitle = utterance.replace(" ", "").lower()
        except:
            productTitle = message.data["name"].replace("-", "").replace(" ", "").lower()
            
        global productAddList
        global shopPage
        shopPage = "main"
        
        for x in productBlob['uk']['ghs']['products']['results']:
            mapProduct = x['name'].replace("-", "").replace(" ", "").lower()
            if mapProduct == productTitle:
                productQty = 1
                productPrice = x['price']
                productName = x['name']
                productImage = x['image']
                productId = self.gen_rand_id()
                productAddList.append({"quantity": productQty, "price": productPrice, "name": productName, "image": productImage, "id": productId})
                self.enclosure.bus.emit(Message("metadata", {"type": "shopping-demo", "itemCartCount": len(productAddList)}))
        
    @intent_handler(IntentBuilder("RemoveProduct").require("RemoveProductKeyword").build())
    def handle_remove_product_intent(self, message):
        """
        Remove Product
        """
        global productAddList
        global productObject
        global checkoutPrice
        try:
            utterance = message.data.get('utterance').lower()
            utterance = utterance.replace(message.data.get('RemoveProductKeyword'), '')
            self.getProductMatch(utterance);
            productTitle = utterance.replace(" ", "").lower()
        except:
            productId = message.data["id"]
        
        for i, d in enumerate(productAddList):
            if d['id'] == productId:
                productAddList.pop(i)
                break
        
        productObject['products'] = productAddList
        cartProductsBlob = productObject
        totalPrice = self.get_total()
        checkoutPrice = totalPrice
        self.enclosure.bus.emit(Message("metadata", {"type": "shopping-demo/cart", "dataCartBlob": cartProductsBlob, "totalPrice": totalPrice}))
    
    @intent_handler(IntentBuilder("Checkout").require("CheckoutKeyword").build())
    def handle_checkout_intent(self, message):
        """
        Checkout
        """
        print("Here")
        
    @intent_handler(IntentBuilder("ViewCart").require("ViewCartKeyword").build())
    def handle_viewcart_intent(self, message):
        """
        ViewCart
        """    
        global productObject
        global productAddList
        global priceOfItems
        global checkoutPrice
        productObject['products'] = productAddList
        cartProductsBlob = productObject
        totalPrice = self.get_total()
        checkoutPrice = totalPrice
        self.enclosure.bus.emit(Message("metadata", {"type": "shopping-demo/cart", "dataCartBlob": cartProductsBlob, "totalPrice": totalPrice}))
        
    @intent_handler(IntentBuilder("ClearCart").require("ClearCartKeyword").build())
    def handle_clearcart_intent(self, message):
        """
        Clear Cart
        """   
        global productObject
        global productAddList
        global shopPage
        global productBlob
        productAddList.clear()
        productObject['products'] = productAddList
        cartProductsBlob = productObject
        totalPrice = self.get_total()
        if shopPage == "cart":
            self.enclosure.bus.emit(Message("metadata", {"type": "shopping-demo/cart", "dataCartBlob": cartProductsBlob, "totalPrice": totalPrice}))
            priceOfItems.clear()
        elif shopPage == "main":
            self.enclosure.bus.emit(Message("metadata", {"type": "shopping-demo", "itemCartCount": len(productAddList)}))
            priceOfItems.clear()
                    
    @intent_handler(IntentBuilder("ShopDemoPage").require("ShopDemoKeyword").build())
    def handle_shop_demo_page_intent(self, message):
        """
        Get Page Context
        """   
        utterance = message.data.get('utterance').lower()
        utterance = utterance.replace(message.data.get('ShopDemoKeyword'), '')
        searchString = utterance.replace(" ", "").lower()
        global shopPage
        shopPage = searchString
        print(shopPage)
        
    def gen_rand_id(self):
        randomId = ''.join([random.choice(string.ascii_letters 
            + string.digits) for n in range(5)])
        return randomId
    
    def get_total(self):
        global productObject
        global productAddList
        global priceOfItems
        
        getPrice = 0
        priceOfItems.clear()
        for x in productObject['products']:
            try:
                priceOfItems.append(x['price'])
                getPrice = sum(priceOfItems)
            except:
                getPrice = 0
        
        return getPrice
    
    def get_shop_cart_count(self):
        global productAddList
        self.enclosure.bus.emit(Message("metadata", {"type": "shopping-demo", "itemCartCount": len(productAddList)}))

    def handle_checkout(self):
        global checkoutPrice
        paymentProviderObject = {}
        paymentProviders = [{"providerName": "PayPal", "providerImage": "http://assets.stickpng.com/thumbs/580b57fcd9996e24bc43c530.png"}, {"providerName": "Visa", "providerImage": "https://seeklogo.net/wp-content/uploads/2016/11/visa-logo-preview-400x400.png"}, {"providerName": "Mastercard", "providerImage": "http://vectorlogofree.com/wp-content/uploads/2012/10/maestro-card-vector-logo-400x400.png"}]
        paymentProviderObject['providers'] = paymentProviders
        self.enclosure.bus.emit(Message("metadata", {"type": "shopping-demo/checkout", "paymentCartBlob": paymentProviderObject, 'totalPrice': checkoutPrice}))

    def complete_payment(self):
        self.handle_clearcart_intent("clear")
        addressObject = {"Street": "85  Crown Street", "City": "London", "Zip": "WC1V 6UG", "Phone": "070-08300467", "Fullname": "Jack N.Brandy"}
        self.enclosure.bus.emit(Message("metadata", {"type": "shopping-demo/payment", "userAddress": addressObject}))

    def stop(self):
        """
        Mycroft Stop Function
        """
        pass
    
def create_skill():
    """
    Mycroft Create Skill Function
    """
    return ShoppingDemoSkill()
