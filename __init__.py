"""
Shopping Demo Mycroft Skill.
"""
import random
import time
import requests
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

class ShoppingDemoSkill(MycroftSkill):
    def __init__(self):
        """
        Shopping Demo Skill Class.
        """    
        super(ShoppingDemoSkill, self).__init__(name="ShoppingDemoSkill")

    @intent_handler(IntentBuilder("SearchProduct").require("SearchProductKeyword").build())
    def handle_search_product_intent(self, message):
        """
        Search Product
        """    
        utterance = message.data.get('utterance').lower()
        utterance = utterance.replace(message.data.get('SearchProductKeyword'), '')
        searchString = utterance
        api_key = ""
        headers = {'Ocp-Apim-Subscription-Key': api_key}
        product = searchString
        offset = "0"
        limit = "10"
        url = "https://dev.tescolabs.com/grocery/products/?query={0}&offset={1}&limit={2}".format(product, offset, limit)
        response = requests.get(url, headers=headers)
        result_search = response.json()
        global productBlob
        productBlob = result_search
        self.enclosure.bus.emit(Message("metadata", {"type": "shopping-demo", "dataBlob": productBlob['uk']['ghs']['products']}))
        
    @intent_handler(IntentBuilder("AddProduct").require("AddProductKeyword").build())
    def handle_add_product_intent(self, message):
        """
        Add Product
        """    
        utterance = message.data.get('utterance').lower()
        utterance = utterance.replace(message.data.get('AddProductKeyword'), '')
        searchString = utterance
        
    @intent_handler(IntentBuilder("RemoveProduct").require("RemoveProductKeyword").build())
    def handle_remove_product_intent(self, message):
        """
        Remove Product
        """    
        utterance = message.data.get('utterance').lower()
        utterance = utterance.replace(message.data.get('RemoveProductKeyword'), '')
        searchString = utterance
    
    @intent_handler(IntentBuilder("IncreaseQty").require("IncreaseQtyKeyword").build())
    def handle_increase_qty_intent(self, message):
        """
        Increase Product Qty
        """    
        utterance = message.data.get('utterance').lower()
        utterance = utterance.replace(message.data.get('IncreaseQtyKeyword'), '')
        searchString = utterance

    @intent_handler(IntentBuilder("DecreaseQty").require("DecreaseQtyKeyword").build())
    def handle_decrease_qty_intent(self, message):
        """
        Decrease Product Qty
        """    
        utterance = message.data.get('utterance').lower()
        utterance = utterance.replace(message.data.get('DecreaseQtyKeyword'), '')
        searchString = utterance    
    
    @intent_handler(IntentBuilder("Checkout").require("CheckoutKeyword").build())
    def handle_checkout_intent(self, message):
        """
        Checkout
        """    
        utterance = message.data.get('utterance').lower()
        utterance = utterance.replace(message.data.get('CheckoutKeyword'), '')
        searchString = utterance    
    
    
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
