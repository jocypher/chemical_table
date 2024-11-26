#!/bin/bash

# PSQL variable to interact with the database
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# Function to handle no argument input
if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
  exit
fi

# Store input argument (atomic number, symbol, or name)
ELEMENT_INPUT=$1

# Check if the input is a number (atomic number)
if [[ "$ELEMENT_INPUT" =~ ^[0-9]+$ ]]; then
  # Query using atomic number
  RESULT=$($PSQL "SELECT e.atomic_number, e.name, e.symbol, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius, pt.type 
                  FROM elements e 
                  JOIN properties p ON e.atomic_number = p.atomic_number
                  JOIN types pt ON p.type_id = pt.type_id
                  WHERE e.atomic_number = $ELEMENT_INPUT;")
else
  # Query using symbol or name
  RESULT=$($PSQL "SELECT e.atomic_number, e.name, e.symbol, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius, pt.type 
                  FROM elements e 
                  JOIN properties p ON e.atomic_number = p.atomic_number
                  JOIN types pt ON p.type_id = pt.type_id
                  WHERE e.symbol = '$ELEMENT_INPUT' OR e.name = '$ELEMENT_INPUT';")
fi

# Check if the result is empty (meaning no matching element was found)
if [[ -z $RESULT ]]
then
  echo "I could not find that element in the database."
else
  # Properly format and display the result
  # The result will be in the format of 'atomic_number name symbol atomic_mass melting_point boiling_point type'
  # We'll use IFS to handle the space-separated values correctly.
  echo "$RESULT" | while IFS='|' read ATOMIC_NUMBER NAME SYMBOL ATOMIC_MASS MELTING_POINT BOILING_POINT TYPE
  do
    # If atomic mass has trailing zeros, remove them
    ATOMIC_MASS=$(echo $ATOMIC_MASS | sed 's/\.0$//')

    # Format the output exactly as required
    echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
  done
fi
