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
from word2number import w2n

__author__ = 'aix'

LOGGER = getLogger(__name__)
productBlob = ""
productObject = {}
productAddList = []
priceOfItems = []
multiProductListAdd = {}
multiProductListRemove = {}
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
        global productObject
        productObject['products'] = productAddList
        
        if len(productAddList) > 0:
            #self.enclosure.bus.emit(Message("metadata", {"type": "shopping-demo", "secondaryTypes": ["shopping-demo/cart"], "dataBlob": productBlob['uk']['ghs']['products'], "itemCartCount": len(productAddList), "dataCartBlob": productObject}))
            self.gui["dataBlob"] = productBlob['uk']['ghs']['products']
            self.gui["itemCartCount"] = len(productAddList)
            self.gui["dataCartBlob"] = productObject
            self.gui.show_page("Cart.qml")
        else:
            #self.enclosure.bus.emit(Message("metadata", {"type": "shopping-demo", "dataBlob": productBlob['uk']['ghs']['products'], "itemCartCount": len(productAddList), "dataCartBlob": productObject}))
            self.gui["dataBlob"] = productBlob['uk']['ghs']['products']
            self.gui["itemCartCount"] = len(productAddList)
            self.gui["dataCartBlob"] = productObject
            self.gui.show_page("Search.qml")
            
    @intent_handler(IntentBuilder("AddProduct").require("AddProductKeyword").build())
    def handle_add_product_intent(self, message):
        """
        Add Product
        """
        global productAddList
        global shopPage
        global productObject
        global productBlob
        shopPage = "main"
        try:
            utterance = message.data.get('utterance').lower()
            utterance = utterance.replace(message.data.get('AddProductKeyword'), '')
            print(utterance)
            productRank = self.rank_product(utterance)
            productObject['products'] = productAddList
            if len(productRank) < 1: 
                self.speak('Sorry no product found')
            elif len(productRank) > 1:
                self.speak('Found multiple items, please select an item number for the product you wish to add', expect_response=True)
                self.handle_multiple_products_add(productRank)
            else:
                productTitle = productRank[0]['name'].replace("-", "").replace(" ", "").lower()
                for x in productBlob['uk']['ghs']['products']['results']:
                    mapProduct = x['name'].replace("-", "").replace(" ", "").lower()
                    if mapProduct == productTitle:
                        productQty = 1
                        productPrice = x['price']
                        productName = x['name']
                        productImage = x['image']
                        productId = self.gen_rand_id()
                        productAddList.append({"quantity": productQty, "price": productPrice, "name": productName, "image": productImage, "id": productId})
                        #self.enclosure.bus.emit(Message("metadata", {"type": "shopping-demo", "secondaryTypes": ["shopping-demo/cart"], "itemCartCount": len(productAddList), "dataCartBlob": productObject, "totalPrice": self.get_total()}))
                        self.gui["itemCartCount"] = len(productAddList)
                        self.gui["dataCartBlob"] = productObject
                        self.gui["totalPrice"] = self.get_total()
                        self.gui.show_page("Search.qml")
                        
        except:
            print(message.data["name"])
            productTitle = message.data["name"].replace("-", "").replace(" ", "").lower()
            productObject['products'] = productAddList
            
            for x in productBlob['uk']['ghs']['products']['results']:
                mapProduct = x['name'].replace("-", "").replace(" ", "").lower()
                if mapProduct == productTitle:
                    productQty = 1
                    productPrice = x['price']
                    productName = x['name']
                    productImage = x['image']
                    productId = self.gen_rand_id()
                    productAddList.append({"quantity": productQty, "price": productPrice, "name": productName, "image": productImage, "id": productId})
                    #self.enclosure.bus.emit(Message("metadata", {"type": "shopping-demo", "secondaryTypes": ["shopping-demo/cart"], "itemCartCount": len(productAddList), "dataCartBlob": productObject, "totalPrice": self.get_total()}))
                    self.gui["itemCartCount"] = len(productAddList)
                    self.gui["dataCartBlob"] = productObject
                    self.gui["totalPrice"] = self.get_total()
                    self.gui.show_page("Search.qml")
        
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
            productRemoveRank = self.rank_product_remove(utterance)
            if len(productRemoveRank) < 1:
                self.speak('Sorry no matching product found')
            elif len(productRemoveRank) > 1:
                self.speak('Found multiple items, please select an item number for the product you wish to remove', expect_response=True)
                self.handle_multiple_products_remove(productRemoveRank)
            else:
                productId = productRemoveRank[0]['id']
                for i, d in enumerate(productAddList):
                    if d['id'] == productId:
                        productAddList.pop(i)
                        break

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
        #self.enclosure.bus.emit(Message("metadata", {"type": "shopping-demo/cart", "dataCartBlob": cartProductsBlob, "itemCartCount": len(productAddList), "totalPrice": totalPrice}))
        self.gui["dataCartBlob"] = cartProductsBlob
        self.gui["itemCartCount"] = len(productAddList)
        self.gui["totalPrice"] = totalPrice
        self.gui.show_page("Cart.qml")
    
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
        #self.enclosure.bus.emit(Message("metadata", {"type": "shopping-demo/cart", "dataCartBlob": cartProductsBlob, "totalPrice": totalPrice}))
        self.gui["dataCartBlob"] = cartProductsBlob
        self.gui["totalPrice"] = totalPrice
        self.gui.show_page("Cart.qml")
        
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
        priceOfItems.clear()
        #self.enclosure.bus.emit(Message("metadata", {"type": "shopping-demo", "resetWorkflowToStep": "1", "itemCartCount": len(productAddList), "dataCartBlob": cartProductsBlob, "totalPrice": totalPrice}))
        self.gui["resetWorkflowToStep"] = 1
        self.gui["itemCartCount"] = len(productAddList)
        self.gui["dataCartBlob"] = cartProductsBlob
        self.gui["totalPrice"] = totalPrice
        self.gui.show_page("Search.qml")
                    
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
        
    @intent_handler(IntentBuilder("AddProductById").require("AddProductByIdKeyword").build())
    def handle_add_product_by_id_intent(self, message):
        """
        Add Product By ID for VUI
        """ 
        global multiProductListAdd
        utterance = message.data.get('utterance').lower()
        utterance = utterance.replace(message.data.get('AddProductByIdKeyword'), '')
        searchString = utterance.replace(" ", "").lower()
        getNum = w2n.word_to_num(searchString)
        getProdName = multiProductListAdd['results'][int(getNum)]['name']
        formatMessage = "add product {0}".format(getProdName)
        self.enclosure.bus.emit(Message("recognizer_loop:utterance", {"utterances": [formatMessage], "lang": "en-us"}));
        multiProductListAdd['results'] = []
        #self.enclosure.bus.emit(Message("metadata", {"type": "shopping-demo", "multipleProductsAddBlob": multiProductListAdd}))
        self.gui["multipleProductsAddBlob"] = multiProductListAdd
        self.gui.show_page("Search.qml")

    @intent_handler(IntentBuilder("RemoveProductById").require("RemoveProductByIdKeyword").build())
    def handle_remove_product_by_id_intent(self, message):
        """
        Remove Product By ID for VUI
        """ 
        global multiProductListRemove
        utterance = message.data.get('utterance').lower()
        utterance = utterance.replace(message.data.get('RemoveProductByIdKeyword'), '')
        searchString = utterance.replace(" ", "").lower()
        getNum = w2n.word_to_num(searchString)
        getProdName = multiProductListRemove['results'][int(getNum)]['name']
        formatMessage = "remove product {0}".format(getProdName)
        self.enclosure.bus.emit(Message("recognizer_loop:utterance", {"utterances": [formatMessage], "lang": "en-us"}));
        multiProductListRemove['results'] = []
        #self.enclosure.bus.emit(Message("metadata", {"type": "shopping-demo/cart", "multipleProductsRemoveBlob": multiProductListRemove}))
        self.gui["multipleProductsRemoveBlob"] = multiProductListRemove
        self.gui.show_page("Cart.qml")

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
        #self.enclosure.bus.emit(Message("metadata", {"type": "shopping-demo", "itemCartCount": len(productAddList)}))
        self.gui["itemCartCount"] = len(productAddList)
        self.gui.show_page("Search.qml")
        
    def handle_checkout(self):
        global checkoutPrice
        paymentProviderObject = {}
        paymentProviders = [{"providerName": "PayPal", "providerImage": "http://assets.stickpng.com/thumbs/580b57fcd9996e24bc43c530.png"}, {"providerName": "Visa", "providerImage": "https://seeklogo.net/wp-content/uploads/2016/11/visa-logo-preview-400x400.png"}, {"providerName": "Mastercard", "providerImage": "http://vectorlogofree.com/wp-content/uploads/2012/10/maestro-card-vector-logo-400x400.png"}]
        paymentProviderObject['providers'] = paymentProviders
        #self.enclosure.bus.emit(Message("metadata", {"type": "shopping-demo/checkout", "paymentCartBlob": paymentProviderObject, 'totalPrice': checkoutPrice}))
        self.gui["paymentCartBlob"] = paymentProviderObject
        self.gui["totalPrice"] = checkoutPrice
        self.gui.show_page("Checkout.qml")
        
    def complete_payment(self):
        self.handle_clearcart_intent("clear")
        addressObject = {"Street": "85  Crown Street", "City": "London", "Zip": "WC1V 6UG", "Phone": "070-08300467", "Fullname": "Jack N.Brandy"}
        #self.enclosure.bus.emit(Message("metadata", {"type": "shopping-demo/payment", "resetWorkflowToStep": "-1", "userAddress": addressObject}))
        self.gui["resetWorkflowToStep"] = -1
        self.gui["userAddress"] = addressObject
        self.gui.show_page("Payment.qml")
        
    def rank_product(self, utterance):
        split_words = utterance.lower().split()
        global productBlob
        print(productBlob)
        search_result = productBlob['uk']['ghs']['products']['results']
        found_products = []
        for product in search_result:
            rank = 0
            split_title = product['name'].lower().split()
            for words in split_words:
                for title_words in split_title: 
                    if words == title_words: 
                        rank += 1
                        break
            product['rank'] = rank
            if (rank > 1):
                if len(found_products) > 0: 
                    for p in found_products:
                        if product['rank'] > p['rank']:
                            if product not in found_products: 
                                found_products = []
                                found_products.append(product)
                                break
                        elif product['rank'] == p['rank']:
                            if product not in found_products: 
                                found_products.append(product)
                else: 
                    found_products.append(product)

        return found_products  

    def rank_product_remove(self, utterance):
        split_words = utterance.lower().split()
        
        global productObject
        search_result = productObject['products']
        found_products = []
        for product in search_result:
            rank = 0
            split_title = product['name'].lower().split()
            for words in split_words:
                for title_words in split_title: 
                    if words == title_words: 
                        rank += 1
                        break
            product['rank'] = rank
            if (rank > 1):
                if len(found_products) > 0: 
                    for p in found_products:
                        if product['rank'] > p['rank']:
                            if product not in found_products: 
                                found_products = []
                                found_products.append(product)
                                break
                        elif product['rank'] == p['rank']:
                            if product not in found_products: 
                                found_products.append(product)
                else: 
                    found_products.append(product)

        return found_products


    def handle_multiple_products_add(self, prodlist):
        global multiProductListAdd
        multiProductListAdd['results'] = prodlist
        #self.enclosure.bus.emit(Message("metadata", {"type": "shopping-demo", "multipleProductsAddBlob": multiProductListAdd}))
        self.gui["multipleProductsAddBlob"] = multiProductListAdd
        self.gui.show_page("Search.qml")

    def handle_multiple_products_remove(self, prodlist):
        global multiProductListRemove
        multiProductListRemove['results'] = prodlist
        #self.enclosure.bus.emit(Message("metadata", {"type": "shopping-demo/cart", "multipleProductsRemoveBlob": multiProductListRemove}))
        self.gui["multipleProductsRemoveBlob"] = multiProductListRemove
        self.gui.show_page("Cart.qml")
    
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
