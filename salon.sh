#!/bin/bash
echo -e "\n~~~~~ MY SALON ~~~~~\n"


PSQL="psql -X --username=freecodecamp --dbname=salon --no-align --tuples-only -c"

MAIN_MENU(){
  if [[ $1 ]]
  then
  echo -e "\n$1"
  fi

  echo -e "\nWelcome to My Salon, how can I help you?\n"

  #SERVICE_IDS=$($PSQL "select service_id from services order by service_id")
  #SERVICE_NAME=$($PSQL "select name from services order by service_id")
  SERVICE_LIST=$($PSQL "select service_id, name from services order by service_id")

#VAILABLE_BIKES=$($PSQL "SELECT bike_id, type, size FROM bikes WHERE available = true")
#echo -e "$SERVICE_IDS"
#echo "$SERVICE_NAME"
#echo "$SERVICE_LIST"

  echo -e "$SERVICE_LIST" | while IFS="|" read SERVICE_ID SERVICE_NAME

  do
    #echo "$SERVICE_ID" | sed "s/|/) /"
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
  echo -e "10\n"

  read SERVICE_ID_SELECTED
  if [[ $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    SERVICE_ID_CHECK=$($PSQL "select service_id from services where service_id=$SERVICE_ID_SELECTED")
    if [[ -z $SERVICE_ID_CHECK ]]
    then
        MAIN_MENU "\nI could not find that service. What would you like today?"
    else
        BOOK_SERVICE $SERVICE_ID_SELECTED;
    fi
  else
    MAIN_MENU "\nI could not find that service. What would you like today?"  
  fi
}

BOOK_SERVICE() {
  if [[ $1 ]]
  then
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$1")
    echo -e "$SERVICE_NAME to be booked"
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    
    if [[ $CUSTOMER_PHONE =~ ^[0-9]+(-[0-9]+)+$ ]]
    then
        # check cusotmer phone exists and get ID
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
        # if not, get customer name
        if [[ -z $CUSTOMER_ID ]]
        then
            echo -e "\nI don't have a record for that phone number, what's your name?"
            IFS=$'\n\t\r' read CUSTOMER_NAME
            ADD_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
            CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
        else
            CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
        fi
     # ask for time
      echo -e "\nWhat time would you like your cut, $CUSTOMER_NAME?"
      read SERVICE_TIME
    # book appointment
      BOOKING_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $1, '$SERVICE_TIME')")

      echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
    else
      echo -e "That is not a valid number.\n"
      BOOK_SERVICE $1

    fi
    fi

}

MAIN_MENU
