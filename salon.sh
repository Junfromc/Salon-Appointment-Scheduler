#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~~~ MY SALON ~~~~~\n"
MAIN_MENU(){
  if [[ $1 ]]
  then
    echo -e "\n$1"
  else
    echo "Welcome to My Salon, how can I help you?"
  fi

  SERVICES=$($PSQL "SELECT * FROM services ORDER BY service_id")
  echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo -e "\n$SERVICE_ID) $NAME"
  done
  APPOINTMENT_MENU
}

APPOINTMENT_MENU() {
  read SERVICE_ID_SELECTED
  if [[ ! $SERVICE_ID_SELECTED =~ ^[1-5]$ ]]
  then
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    # check customer phone in customers table.
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
    
    if [[ -z $CUSTOMER_NAME ]]
    then
      # if customer not exists in customers table
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      if [[ -z $CUSTOMER_NAME ]]
      then
        MAIN_MENU "Your name can not be empty. Please try again!"
      fi
      INSERT_INTO_CUSTOMERS=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    fi
    # if customer exists in customers table.
    SERVICE_NAME_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    echo -e "\nWhat time would you like your $(echo $SERVICE_NAME_SELECTED | sed 's/^ *| *$//g'), $CUSTOMER_NAME?"
    read SERVICE_TIME
    if [[ ! $SERVICE_TIME ]]
    then
      MAIN_MENU "Service time can not be empty. Please try again!"
    fi
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    INSERT_INTO_APPOINTMENTS=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    echo -e "\nI have put you down for a $(echo $SERVICE_NAME_SELECTED | sed 's/^ *| *$//g') at $SERVICE_TIME, $CUSTOMER_NAME."
    EXIT
  fi
}

EXIT(){
  echo -e "\nThanks for your appointment."
}
MAIN_MENU
