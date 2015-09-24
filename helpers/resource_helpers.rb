#!/usr/bin/env ruby
# encoding: utf-8

require 'json'

module ResourceHelpers
  def json(key, text = 'The above command returns an object structured like this:')
    hash = get_resource(key)
    hash = yield hash if block_given?

    write_json(hash, text)
  end

  def json_paged_resource(key, rel, total_items = 100, query = nil)
    resource = get_resource(key)
    resource = yield resource if block_given?

    url = LINK_RELATION_HREFS[rel]
    start_of_query = ""
    start_of_query << query + "&" unless query.nil?

    paged_resource = {
      "total_items" => total_items,
      "page" => 1,
      "page_size" => 1,
      "_links" => {
        "self" => {
          "href" => url + "?#{start_of_query}page=1&page_size=1",
          "title" => nil,
          "templated" => false
        },
        "next" => {
          "href" => url + "?#{start_of_query}page=2&page_size=1",
          "title" => nil,
          "templated" => false
        },
        "last" => {
          "href" => url + "?#{start_of_query}page=#{total_items}&page_size=1",
          "title" => nil,
          "templated" => false
        }
      },
      "_embedded" => {
        "items" => [
          resource
        ]
      }
    }

    write_json(paged_resource, 'The above command returns an object structured like this:')
  end

  def json_paged_versioned_resource(key, embedded_key, rel, total_items = 100)
    resource = get_resource(key)
    embedded_resource = get_resource(embedded_key)

    url = LINK_RELATION_HREFS[rel]

    paged_versioned_resource = {
      "total_items" => total_items,
      "page" => 1,
      "page_size" => 1,
      "_links" => {
        "self" => {
          "href" => url + "?sort=resource_version&page_size=1",
          "title" => nil,
          "templated" => false
        },
        "next" => {
          "href" => url + "?resource_version&min_resource_version=1234567890&page_size=1",
          "title" => nil,
          "templated" => false
        }
      },
      "_embedded" => {
        "deleted_items" => [
          embedded_resource
        ],
        "items" => [
          resource
        ]
      }
    }

    write_json(paged_versioned_resource, 'The above command returns an object structured like this:')
  end

  def write_json(resource, text)
    "> #{text}\n\n" << "~~~ json\n#{JSON.pretty_generate(resource)}\n~~~"
  end

  def get_resource(key)
    hash = case key
      when Hash
        h = {}
        key.each { |k, v| h[k.to_s] = v }
        h
      when Array
        key
      else ResourceHelpers.const_get(key.to_s.upcase)
    end
  end

  CLIENT_CREDENTIALS_TOKEN ||= {
    "access_token" => "pYXQiOjE0MjI1MzY0NjEsInNjb3BlIjo",
    "token_type" => "bearer",
    "expires_in" => 86400,
    "scope" => ""
  }

  ACCESS_TOKEN ||= {
    "access_token" => CLIENT_CREDENTIALS_TOKEN["access_token"],
    "token_type" => CLIENT_CREDENTIALS_TOKEN["token_type"],
    "expires_in" => 3600,
    "refresh_token" => "tGzv3JOkF0XG5Qx2TlKWIA",
    "scope" => "read:user write:user"
  }

  REFRESH_GRANT_ACCESS_TOKEN ||= {
    "access_token" => "03807cb390319329bdf6c777d4dfae9c0d3b3c35",
    "token_type" => CLIENT_CREDENTIALS_TOKEN["token_type"],
    "expires_in" => ACCESS_TOKEN["expires_in"],
    "refresh_token" => "2YotnFZFEjr1zCsicMWpAA",
    "scope" => ACCESS_TOKEN["scope"]
  }

  VALIDATION_ERROR ||= {
    "code" => "validation_failed",
    "message" => nil,
    "errors" => {
      "address.postal_code" => [
        "Zip Code is invalid"
      ]
    }
  }

  USER_AGENT_ERROR ||= {
    "code" => "user_agent_required",
    "message" => "All requests must include a valid User-Agent header"
  }

  MONEY ||= {
    "amount" => 25.65,
    "currency_code" => "USD",
    "display" => "$25.65"
  }

  MONEY_FEE ||= {
    "amount" => 5.35,
    "currency_code" => "USD",
    "display" => "$5.35"
  }

  MONEY_PROCEEDS ||= {
    "amount" => 22.58,
    "currency_code" => "USD",
    "display" => "$22.58"
  }

  MONEY_ZERO ||= {
    "amount" => 0,
    "currency_code" => "USD",
    "display" => "$0.00"
  }

  MONEY_TOTAL ||= {
    "amount" => 30,
    "currency_code" => "USD",
    "display" => "$30.00"
  }

  MONEY_EURO ||= {
    "amount" => 22.62,
    "currency_code" => "EUR",
    "display" => '€22.62'
  }

  SEATING ||= {
    "section" => "107",
    "row" => "A",
    "seat_from" => "1",
    "seat_to" => "4"
  }

  ADDRESS_SNAPSHOT ||= {
    "full_name" => "Joe Smith",
    "address_1" => "Flat 16, Waterman's Quay",
    "address_2" => "33 William Morris Way",
    "address_3" => "Fulham",
    "city" => "London",
    "state_province" => "Greater London",
    "postal_code" => "SW6 2UU",
    "country_code" => "GB",
    "country" => "United Kingdom"
  }

  ROOT ||= {
    "_links" => {
      "self" => {
        "href" => "https://api.viagogo.net/v2/",
        "title" => nil,
        "templated" => false
      },
      "viagogo:user" => {
        "href" => "https://api.viagogo.net/v2/user",
        "title" => "Account Settings",
        "templated" => false
      },
      "viagogo:search" => {
        "href" => "https://api.viagogo.net/v2/search",
        "title" => "Search",
        "templated" => false
      },
      "viagogo:genres" => {
        "href" => "https://api.viagogo.net/v2/categories/0/children",
        "title" => "Browse",
        "templated" => false
      },
      "viagogo:countries" => {
        "href" => "https://api.viagogo.net/v2/countries",
        "title" => "Country",
        "templated" => false
      },
      "viagogo:currencies" => {
        "href" => "https://api.viagogo.net/v2/currencies",
        "title" => "Currency",
        "templated" => false
      },
      "viagogo:languages" => {
        "href" => "https://api.viagogo.net/v2/languages",
        "title" => "Language",
        "templated" => false
      },
      "viagogo:venues" => {
        "href" => "https://api.viagogo.net/v2/venues",
        "title" => "Venue",
        "templated" => false
      },
      "viagogo:metroareas" => {
        "href" => "https://api.viagogo.net/v2/metroareas",
        "title" => "Metro Area",
        "templated" => false
      }
    }
  }

  COUNTRY ||= {
    "code" => "GB",
    "name" => "United Kingdom",
    "_links" => {
      "self" => {
        "href" => "https://api.viagogo.net/v2/countries/GB",
        "title" => nil,
        "templated" => false
      }
    }
  }

  CURRENCY ||= {
    "code" => "USD",
    "name" => "United States Dollar",
    "symbol" => "$",
    "_links" => {
      "self" => {
        "href" => "https://api.viagogo.net/v2/currencies/USD",
        "title" => nil,
        "templated" => false
      }
    }
  }

  LANGUAGE ||= {
    "code" => "en-us",
    "name" => "English (US)",
    "_links" => {
      "self" => {
        "href" => "https://api.viagogo.net/v2/languages/en-us",
        "title" => nil,
        "templated" => false
      }
    }
  }

  USER ||= {
    "full_name" => ADDRESS_SNAPSHOT["full_name"],
    "email" => "joe.smith@email.com",
    "primary_phone" => "+447654321098",
    "email_optin" => false,
    "_links" => {
      "self" => {
        "href" => "https://api.viagogo.net/v2/user",
        "title" => "Account Settings",
        "templated" => false
      },
      "user:update" => {
        "href" => "https://api.viagogo.net/v2/user",
        "title" => nil,
        "templated" => false
      },
      "user:addresses" => {
        "href" => "https://api.viagogo.net/v2/addresses",
        "title" => "Addresses",
        "templated" => false
      },
      "user:paymentmethods" => {
        "href" => "https://api.viagogo.net/v2/paymentmethods",
        "title" => "Payment Methods",
        "templated" => false
      },
      "user:purchases" => {
        "href" => "https://api.viagogo.net/v2/purchases",
        "title" => "Purchases",
        "templated" => false
      },
      "user:sales" => {
        "href" => "https://api.viagogo.net/v2/sales",
        "title" => "Sales",
        "templated" => false
      },
      "user:sellerlistings" => {
        "href" => "https://api.viagogo.net/v2/sellerlistings",
        "title" => "Listings",
        "templated" => false
      }
    }
  }

  ADDRESS ||= {
    "id" => 34115,
    "full_name" => ADDRESS_SNAPSHOT["full_name"],
    "default" => true,
    "address_1" => ADDRESS_SNAPSHOT["address_1"],
    "address_2" => ADDRESS_SNAPSHOT["address_2"],
    "address_3" => ADDRESS_SNAPSHOT["address_3"],
    "city" => ADDRESS_SNAPSHOT["city"],
    "state_province" => ADDRESS_SNAPSHOT["state_province"],
    "postal_code" => ADDRESS_SNAPSHOT["postal_code"],
    "_links" => {
      "self" => {
        "href" => "https://api.viagogo.net/v2/addresses/34115",
        "title" => nil,
        "templated" => false
      },
      "address:update" => {
        "href" => "https://api.viagogo.net/v2/addresses/34115",
        "title" => nil,
        "templated" => false
      },
      "address:delete" => {
        "href" => "https://api.viagogo.net/v2/addresses/34115",
        "title" => nil,
        "templated" => false
      }
    },
    "_embedded" => {
      "country" => COUNTRY
    }
  }

  PAYMENT_METHOD ||= {
    "id" => 95698,
    "details" => "************1111",
    "type" => "CreditCard",
    "type_description" => "Credit or Debit Card",
    "buyer_method" => true,
    "default_buyer_method" => false,
    "seller_method" => false,
    "default_seller_method" => false,
    "_links" => {
      "self" => {
        "href" => "https://api.viagogo.net/v2/paymentmethods/95698",
        "title" => nil,
        "templated" => false
      },
      "paymentmethod:updatedefaults" => {
        "href" => "https://api.viagogo.net/v2/paymentmethods/95698",
        "title" => nil,
        "templated" => false
      },
      "paymentmethod:updatecreditcard" => {
        "href" => "https://api.viagogo.net/v2/paymentmethods/95698?paymentMethodType=CreditCard",
        "title" => nil,
        "templated" => false
      },
      "paymentmethod:delete" => {
        "href" => "https://api.viagogo.net/v2/paymentmethods/95698",
        "title" => nil,
        "templated" => false
      }
    },
    "_embedded" => {
      "billing_address" => ADDRESS
    }
  }

  PAYMENT_METHOD_PAYPAL ||= {
    "id" => PAYMENT_METHOD["id"],
    "details" => USER["email"],
    "type" => "PayPal",
    "type_description" => "PayPal",
    "buyer_method" => PAYMENT_METHOD["buyer_method"],
    "default_buyer_method" => PAYMENT_METHOD["default_buyer_method"],
    "seller_method" => PAYMENT_METHOD["seller_method"],
    "default_seller_method" => PAYMENT_METHOD["default_seller_method"],
    "_links" => PAYMENT_METHOD["_links"],
    "_embedded" => PAYMENT_METHOD["_embedded"]
  }

  METRO_AREA ||={
    "id" =>  65,
    "name" =>  "London",
    "_links" => {
      "self" => {
        "href" =>  "https://api.viagogo.net/v2/metroareas/65",
        "title" =>  nil,
        "templated" =>  false
      },
      "metroarea:events" => {
        "href" => "https://api.viagogo.net/v2/categories/0/events?metro_area_id=65",
        "title" =>  nil,
        "templated" =>  false
      },
      "metroarea:venues" => {
        "href" => "https://api.viagogo.net/v2/venues?metro_area_id=65",
        "title" =>  nil,
        "templated" =>  false
      }
    }
  }

  VENUE ||= {
    "id" => 1364,
    "name" => "The O2 arena",
    "address_1" => "Peninsula Square",
    "address_2" => "",
    "state_province" => "",
    "postal_code" => "SE10 0DX",
    "city" => "London",
    "latitude" => 51.5025,
    "longitude" => 0.0024,
    "_links" => {
      "self" => {
        "href" => "https://api.viagogo.net/v2/venues/1364",
        "title" => nil,
        "templated" => false
      },
      "venue:events" => {
        "href" => "https://api.viagogo.net/v2/categories/0/events?venue_id=1364",
        "title" => nil,
        "templated" => false
      },
      "venue:metroarea" => {
        "href" => "https://api.viagogo.net/v2/metroareas/65",
        "title" => nil,
        "templated" => false
      }
    },
    "_embedded" => {
      "country" => COUNTRY
    }
  }

  EMBEDDED_VENUE ||= {
    "id" => VENUE["id"],
    "name" => VENUE["name"],
    "city" => VENUE["city"],
    "latitude" => VENUE["latitude"],
    "longitude" => VENUE["longitude"],
    "_links" =>  {
      "self" => VENUE["_links"]["self"]
    },
    "_embedded" => VENUE["_embedded"]
  }

  EVENT ||= {
    "id" => 735139,
    "name" => "One Direction",
    "start_date" => "2015-09-24T18:30:00+01:00",
    "end_date" => nil,
    "date_confirmed" => true,
    "min_ticket_price" => MONEY,
    "notes_html" => "General Notes \n • All sales are final \n • Ticket prices are set by the seller and may be above or below face value \n • Event dates and times are subject to change, it is up to you to check local listings for updates \n • After your purchase, you will receive a confirmation email with your ticket delivery details and timing",
    "restrictions_html" => "Everyone <strong>under 15</strong> must be accompanied by an adult.",
    "_links" => {
      "self" => {
        "href" => "https://api.viagogo.net/v2/events/735139",
        "title" => nil,
        "templated" => false
      },
      "event:listings" => {
        "href" => "https://api.viagogo.net/v2/events/735139/listings",
        "title" => "View Tickets",
        "templated" => false
      },
      "event:category" => {
        "href" => "https://api.viagogo.net/v2/categories/20746",
        "title" => nil,
        "templated" => false
      },
      "event:webpage" => {
        "href" => "http://www.viagogo.com/E-735139",
        "title" => nil,
        "templated" => false
      },
      "event:localwebpage" => {
        "href" => "http://www.viagogo.co.uk/E-735139",
        "title" => nil,
        "templated" => false
      },
      "event:listingconstraints" => {
        "href" => "https://api.viagogo.net/v2/events/735139/listingconstraints",
        "title" => nil,
        "templated" => false
      },
      "event:createsellerlisting" => {
        "href" => "https://api.viagogo.net/v2/events/735139/sellerlistings",
        "title" => "Sell Tickets",
        "templated" => false
      }
    },
    "_embedded" => {
      "venue" => EMBEDDED_VENUE
    }
  }

  EMBEDDED_EVENT ||= {
    "id" => EVENT["id"],
    "name" => "One Direction",
    "start_date" => EVENT["start_date"],
    "date_confirmed" => EVENT["date_confirmed"],
    "_links" => {
      "self" => EVENT["_links"]["self"]
    }
  }

  DELETED_EMBEDDED_EVENT ||= {
    "id" => 635139,
    "name" => EVENT["name"],
    "start_date" => "2015-01-24T18:30:00+01:00",
    "date_confirmed" => EVENT["date_confirmed"],
    "_links" => {
      "self" => {
        "href" => "https://api.viagogo.net/v2/events/635139",
        "title" => nil,
        "templated" => false
      }
    }
  }

  SPARSE_VENUE ||= {
    "city" => VENUE["city"]
  }

  SPARSE_EVENT ||= {
    "id" => EVENT["id"],
    "name" => EVENT["name"],
    "_embedded" => {
      "venue" => SPARSE_VENUE
    }
  }

  CATEGORY ||= {
    "id" => 1207,
    "name" => "Rock and Pop",
    "description_html" => "<p>Get your <b>Rock and Pop tickets</b> on viagogo, your online ticket marketplace. Choose an event to see the selection of tickets available or check the Rock and Pop tour on the map to locate the nearest event to you. You can also sell your spare tickets on viagogo, and listing tickets is free. All Rock and Pop tickets are covered by the viagogo Ticket Guarantee!</p>",
    "min_ticket_price" => MONEY,
    "min_event_date" => "2015-02-04T09:15:00+00:00",
    "max_event_date" => "2016-09-10T15:45:00+00:00",
    "_links" => {
      "self" => {
        "href" => "https://api.viagogo.net/v2/categories/1207",
        "title" => nil,
        "templated" => false
      },
      "category:parent" => {
        "href" => "https://api.viagogo.net/v2/categories/3",
        "title" => nil,
        "templated" => false
      },
      "category:children" => {
        "href" => "https://api.viagogo.net/v2/categories/1207/children",
        "title" => nil,
        "templated" => false
      },
      "category:performers" => {
        "href" => "https://api.viagogo.net/v2/categories/1207/children?onlyLeafCategories=true",
        "title" => nil,
        "templated" => false
      },
      "category:events" => {
        "href" => "https://api.viagogo.net/v2/categories/1207/events",
        "title" => nil,
        "templated" => false
      },
      "category:image" => {
        "href" => "http://cdn1.viagogo.net/img/cat/1207/2/1.jpg",
        "title" => nil,
        "templated" => false
      },
      "category:webpage" => {
        "href" => "http://www.viagogo.com/Concert-Tickets/Rock-and-Pop",
        "title" => nil,
        "templated" => false
      }
    }
  }

  CATEGORY_PERFORMER ||= {
    "id" => 20746,
    "name" => "One Direction",
    "description_html" => "One Direction (also known as 1D by their millions of fans worldwide) are Harry Styles, Liam Payne, Louis Tomlinson, Niall Horan and Zayn Malik. Their record breaking studio albums and massive hit tours have seen 1D become a global phenomenon and redefine the meaning of iconic status. With crowds swooning from all over the world to see this boy band live, One Direction are the most in-demand performers of today’s generation. Select a date to view the range of One Direction tickets available to an event near you. You can also sell your spare tickets on viagogo, and listing tickets is free. All One Direction ticket purchases are covered by the viagogo Ticket Guarantee and delivered electronically or via secure courier to more than a 100 countries in the world. viagogo provides choice, convenience and consumer protection so you can buy your One Direction tickets with 100% confidence.</p>",
    "min_ticket_price" => MONEY,
    "min_event_date" => "2015-02-07T07:00:00+00:00",
    "max_event_date" => "2015-10-31T18:30:00+00:00",
    "_links" => {
      "self" => {
        "href" => "https://api.viagogo.net/v2/categories/20746",
        "title" => nil,
        "templated" => false
      },
      "category:parent" => {
        "href" => "https://api.viagogo.net/v2/categories/1207",
        "title" => nil,
        "templated" => false
      },
      "category:events" => {
        "href" => "https://api.viagogo.net/v2/categories/20746/events",
        "title" => nil,
        "templated" => false
      },
      "category:image" => {
        "href" => "http://cdn1.viagogo.net/img/cat/20746/2/1.jpg",
        "title" => nil,
        "templated" => false
      },
      "category:webpage" => {
        "href" => "http://www.viagogo.com/Concert-Tickets/Rock-and-Pop/One-Direction-Tickets",
        "title" => nil,
        "templated" => false
      }
    }
  }

  CATEGORY_GENRE ||= {
    "id" => 3,
    "name" => "Concert Tickets",
    "description_html" => "<p>Get your <b>Concert Tickets tickets</b> on viagogo, your online ticket marketplace. Choose an event to see the selection of tickets available or check the Concert Tickets tour on the map to locate the nearest event to you. You can also sell your spare tickets on viagogo, and listing tickets is free. All Concert Tickets tickets are covered by the viagogo Ticket Guarantee!</p>",
    "min_ticket_price" => MONEY,
    "min_event_date" => "2015-02-05T08:00:00+00:00",
    "max_event_date" => "2016-09-10T15:45:00+00:00",
    "_links" => {
      "self" => {
        "href" => "https://api.viagogo.net/v2/categories/3",
        "title" => nil,
        "templated" => false
      },
      "category:parent" => {
        "href" => "https://api.viagogo.net/v2/categories/0",
        "title" => nil,
        "templated" => false
      },
      "category:children" => {
        "href" => "https://api.viagogo.net/v2/categories/3/children",
        "title" => nil,
        "templated" => false
      },
      "category:performers" => {
        "href" => "https://api.viagogo.net/v2/categories/3/children?onlyLeafCategories=True",
        "title" => nil,
        "templated" => false
      },
      "category:events" => {
        "href" => "https://api.viagogo.net/v2/categories/3/events",
        "title" => nil,
        "templated" => false
      },
      "category:image" => {
        "href" => "http://cdn1.viagogo.net/img/cat/3/1/1.jpg",
        "title" => nil,
        "templated" => false
      },
      "category:webpage" => {
        "href" => "http://www.viagogo.com/Concert-Tickets",
        "title" => nil,
        "templated" => false
      }
    }
  }

  LISTING_NOTE ||= {
    "id" => 11,
    "note" => "Includes VIP pass",
    "_links" => {
      "self" => {
        "href" => "https://api.viagogo.net/v2/listingnotes/11",
        "title" => nil,
        "templated" => false
      }
    }
  }

  TICKET_TYPE ||= {
    "type" => "ETicket",
    "name" => "Print at home / E-tickets (PDF)",
    "_links" => {
      "self" => {
        "href" => "https://api.viagogo.net/v2/tickettypes/ETicket",
        "title" => nil,
        "templated" => false
      }
    }
  }

  SPLIT_TYPE ||= {
    "type" => "Any",
    "name" => "Any",
    "description" => "Allow the tickets to be split up in any way"
  }

  LISTING ||= {
    "id" => 22096065,
    "number_of_tickets" => 1,
    "seating" => SEATING,
    "pickup_available" => false,
    "download_available" => false,
    "ticket_price" => MONEY_EURO,
    "estimated_ticket_price" => MONEY,
    "estimated_total_ticket_price" => MONEY,
    "estimated_booking_fee" => MONEY_FEE,
    "estimated_shipping" => MONEY_ZERO,
    "estimated_vat" => MONEY_ZERO,
    "estimated_total_charge" => MONEY_TOTAL,
    "_links" => {
      "self" => {
        "href" => "https://api.viagogo.net/v2/listings/22096065",
        "title" => nil,
        "templated" => false
      },
      "listing:event" => {
        "href" => "https://api.viagogo.net/v2/events/735139",
        "title" => nil,
        "templated" => false
      },
      "listing:purchasepreview" => {
        "href" => "https://api.viagogo.net/v2/listings/22096065/purchasepreview",
        "title" => "Buy",
        "templated" => false
      },
      "listing:deliverymethods" => {
        "href" => "https://api.viagogo.net/v2/listings/22096065/deliverymethods",
        "title" => nil,
        "templated" => false
      }
    },
    "_embedded" => {
      "listing_notes" => [
        LISTING_NOTE
      ],
      "ticket_type" => TICKET_TYPE
    }
  }

  SELLER_LISTING ||= {
    "id" => 22096065,
    "created_at" => "2015-06-12T15:05:35+01:00",
    "number_of_tickets" => 2,
    "display_number_of_tickets" => nil,
    "seating" => SEATING,
    "face_value" => MONEY_EURO,
    "ticket_price" => MONEY,
    "ticket_proceeds" => MONEY_PROCEEDS,
    "_links" => {
      "self" => {
        "href" => "https://api.viagogo.net/v2/sellerlistings/22096065",
        "title" => nil,
        "templated" => false
      },
      "sellerlisting:constraints" => {
        "href" => "https://api.viagogo.net/v2/sellerlistings/22096065/constraints",
        "title" => nil,
        "templated" => false
      },
      "sellerlisting:updatetickettype" => {
        "href" => "https://api.viagogo.net/v2/sellerlistings/22096065",
        "title" => nil,
        "templated" => false
      },
      "sellerlisting:updateticketprice" => {
        "href" => "https://api.viagogo.net/v2/sellerlistings/22096065",
        "title" => nil,
        "templated" => false
      },
      "sellerlisting:updatesplittype" => {
        "href" => "https://api.viagogo.net/v2/sellerlistings/22096065",
        "title" => nil,
        "templated" => false
      },
      "sellerlisting:updatenumberoftickets" => {
        "href" => "https://api.viagogo.net/v2/sellerlistings/22096065",
        "title" => nil,
        "templated" => false
      },
      "sellerlisting:updateseating" => {
        "href" => "https://api.viagogo.net/v2/sellerlistings/22096065",
        "title" => nil,
        "templated" => false
      },
      "sellerlisting:updateticketlocation" => {
        "href" => "https://api.viagogo.net/v2/sellerlistings/22096065",
        "title" => nil,
        "templated" => false
      },
      "sellerlisting:updatenotes" => {
        "href" => "https://api.viagogo.net/v2/sellerlistings/22096065",
        "title" => nil,
        "templated" => false
      },
      "sellerlisting:unpublish" => {
        "href" => "https://api.viagogo.net/v2/sellerlistings/22096065",
        "title" => nil,
        "templated" => false
      },
      "sellerlisting:delete" => {
        "href" => "https://api.viagogo.net/v2/sellerlistings/22096065",
        "title" => "Delete Listing",
        "templated" => false
      },
      "sellerlisting:updatefacevalue" => {
        "href" => "https://api.viagogo.net/v2/sellerlistings/22096065",
        "title" => nil,
        "templated" => false
      },
      "sellerlisting:ticketlocation" => {
        "href" => "https://api.viagogo.net/v2/addresses/34115",
        "title" => "Ticket Location Address",
        "templated" => false
      }
    },
    "_embedded" => {
      "event" => EMBEDDED_EVENT,
      "venue" => EMBEDDED_VENUE,
      "ticket_type" => TICKET_TYPE,
      "split_type" => SPLIT_TYPE,
      "listing_notes" => [
        LISTING_NOTE
      ]
    }
  }

  LISTING_CONSTRAINTS ||= {
    "min_ticket_price" => MONEY,
    "max_ticket_price" => MONEY,
    "min_number_of_tickets" => 1,
    "max_number_of_tickets" => 99,
    "ticket_location_required" => true,
    "seats_required" => false,
    "sections" => [
      {
        "name" => "General Admission",
        "free_text_row" => false,
        "rows" => []
      }
    ],
    "_links" => {
      "self" => {
        "href" => "https://api.viagogo.net/v2/events/#{EVENT["id"]}/listingconstraints",
        "title" => nil,
        "templated" => false
      }
    },
    "_embedded" => {
      "ticket_types" => [
        TICKET_TYPE
      ],
      "split_types" => [
        SPLIT_TYPE
      ],
      "listing_notes" => [
        LISTING_NOTE
      ],
      "currencies" => [
        CURRENCY
      ]
    }
  }

  SELLER_DELIVERY_METHOD = {
    "id" => 0,
    "name" => "UPS (Express Saver) - United Kingdom Domestic",
    "type" => "Pickup"
  }

  SALE ||= {
    "id" => 1017322,
    "created_at" => "2015-09-21T16:02:39+00:00",
    "seating" => SEATING,
    "proceeds" => MONEY_PROCEEDS,
    "number_of_tickets" => 2,
    "status" => "Confirm Sales",
    "status_description" => nil,
    "confirm_by" => "2015-09-23T16:02:43+00:00",
    "ship_by" => nil,
    "payment_details" => PAYMENT_METHOD["details"],
    "payment_type" => PAYMENT_METHOD["type"],
    "payment_type_description" => PAYMENT_METHOD["type_description"],
    "_links" => {
      "self" => {
        "href" => "https://api.viagogo.net/v2/sales/1017322",
        "title" => nil,
        "templated" => false
      },
      "sale:confirm" => {
        "href" => "https://api.viagogo.net/v2/sales/1017322",
        "title" => "Confirm",
        "templated" => false
      },
      "sale:reject" => {
        "href" => "https://api.viagogo.net/v2/sales/1017322",
        "title" => "Report a problem",
        "templated" => false
      },
      "sale:listing" => SELLER_LISTING["_links"]["self"],
    },
    "_embedded" => {
      "delivery_method" => SELLER_DELIVERY_METHOD,
      "event" => EMBEDDED_EVENT,
      "ticket_type" => TICKET_TYPE,
      "venue" => EMBEDDED_VENUE
    }
  }

  SEARCH_RESULT ||= {
    "title" => "One Direction",
    "type" => "Category",
    "type_description" => "Artist",
    "_links" => {
      "searchresult:category" => {
        "href" => "https://api.viagogo.net/v2/categories/20746",
        "title" => nil,
        "templated" => false
      }
    }
  }

  PICKUP ||= {
    "id" => 2109,
    "start_date" => "2015-09-24T09:00:00+00:00",
    "end_date" => "2015-09-24T17:00:00+00:00",
    "address" => ADDRESS_SNAPSHOT,
    "_links" => {
      "self" => {
        "href" => "https://api.viagogo.net/v2/pickups/2109",
        "title" => nil,
        "templated" => false
      },
      "pickup:delete" => {
        "href" => "https://api.viagogo.net/v2/pickups/2109",
        "title" => nil,
        "templated" => false
      }
    }
  }

  SHIPMENT ||= {
    "id" => 1007247,
    "tracking_number" => "1ZX0565R0490161406",
    "delivery_address" => nil,
    "_links" => {
      "shipment:carrier" => {
        "href" => "https://api.viagogo.net/v2/addresses/37073/carriers/2",
        "title" => nil,
        "templated" => false
      },
      "shipment:label" => {
        "href" => "https://api.viagogo.net/v2/sales/1017898/shipments/1007247/label",
        "title" => nil,
        "templated" => false
      }
    },
    "_embedded" => {
      "delivery_method" => SELLER_DELIVERY_METHOD,
      "pickups" => [
        PICKUP
      ]
    }
  }

  ETICKET ||= {
    "id" => 25827,
    "_links" => {
      "eticket:delete" => {
        "href" => "https://api.viagogo.net/v2/sales/1017322/etickets/25827",
        "title" => nil,
        "templated" => false
      },
      "eticket:document" => {
        "href" => "https://api.viagogo.net/v2/etickets/25827/document",
        "title" => nil,
        "templated" => false
      },
      "eticket:thumbnail" => {
        "href" => "https://api.viagogo.net/v2/etickets/25827/thumbnail",
        "title" => nil,
        "templated" => false
      }
    }
  }

  ETICKETUPLOAD ||= {
    "id" => 4059,
    "file_name" => "Ticket.pdf",
    "processed_at" => "2015-09-24T11:51:44+00:00",
    "original_number_of_etickets" => 1,
    "status_description" => "Processing Complete",
    "_links" => {
      "eticketupload:document" => {
        "href" => "https://api.viagogo.net/v2/eticketuploads/4059/document",
        "title" => nil,
        "templated" => false
      }
    },
    "_embedded" => {
      "etickets" => [
        ETICKET
      ]
    }
  }

  LINK_RELATION_HREFS ||= {
    "category:children" => CATEGORY["_links"]["category:children"]["href"],
    "category:events" => CATEGORY["_links"]["category:events"]["href"],
    "category:performers" => CATEGORY["_links"]["category:performers"]["href"],
    "event:listings" => EVENT["_links"]["event:listings"]["href"],
    "metroarea:events" => METRO_AREA["_links"]["metroarea:events"]["href"],
    "metroarea:venues" => METRO_AREA["_links"]["metroarea:venues"]["href"],
    "venue:events" => VENUE["_links"]["venue:events"]["href"],
    "viagogo:countries" => ROOT["_links"]["viagogo:countries"]["href"],
    "viagogo:currencies" => ROOT["_links"]["viagogo:currencies"]["href"],
    "viagogo:genres" => ROOT["_links"]["viagogo:genres"]["href"],
    "viagogo:languages" => ROOT["_links"]["viagogo:languages"]["href"],
    "viagogo:metroareas" => ROOT["_links"]["viagogo:metroareas"]["href"],
    "viagogo:search" => ROOT["_links"]["viagogo:search"]["href"],
    "viagogo:user" => ROOT["_links"]["viagogo:user"]["href"],
    "viagogo:venues" => ROOT["_links"]["viagogo:venues"]["href"],
    "user:addresses" => USER["_links"]["user:addresses"]["href"],
    "user:paymentmethods" => USER["_links"]["user:paymentmethods"]["href"],
    "user:purchases" => USER["_links"]["user:purchases"]["href"],
    "user:sales" => USER["_links"]["user:sales"]["href"],
    "user:sellerlistings" => USER["_links"]["user:sellerlistings"]["href"],
    "sale:shipments" => "#{SALE["_links"]["self"]["href"]}/shipments",
    "sale:etickets" => "#{SALE["_links"]["self"]["href"]}/etickets",
    "sale:eticketuploads" => "#{SALE["_links"]["self"]["href"]}/eticketuploads"
  }
end