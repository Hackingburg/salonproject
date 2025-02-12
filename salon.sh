#!/bin/bash

# 定义 PSQL 变量用于执行 SQL 查询
PSQL="psql --username=freecodecamp --dbname=salon --no-align --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

# 主菜单函数，显示服务列表
MAIN_MENU() {
    if [[ $1 ]]; then
        echo -e "\n$1"
    fi

    echo "Welcome to My Salon, how can I help you?"
    # 获取服务列表
    SERVICE_LIST=$($PSQL "SELECT service_id, name FROM services")
    # 格式化输出服务列表
    echo "$SERVICE_LIST" | while IFS="|" read -r SERVICE_ID NAME; do
        echo "$SERVICE_ID) $NAME"
    done

    # 提示用户输入服务 ID
    read SERVICE_ID_SELECTED

    # 检查服务 ID 是否存在
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    if [[ -z $SERVICE_NAME ]]; then
        # 若服务 ID 不存在，重新显示服务列表
        MAIN_MENU "I could not find that service. What would you like today?"
    else
        # 提示用户输入电话号码
        echo -e "\nWhat's your phone number?"
        read CUSTOMER_PHONE

        # 检查电话号码是否存在于客户表中
        CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
        if [[ -z $CUSTOMER_NAME ]]; then
            # 若电话号码不存在，提示用户输入姓名
            echo -e "\nI don't have a record of that phone number, what's your name?"
            read CUSTOMER_NAME
            # 将新客户信息插入客户表
            INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
        fi

        # 获取客户 ID
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

        # 提示用户输入服务时间
        echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
        read SERVICE_TIME

        # 插入预约信息到预约表
        INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

        # 输出预约成功信息
        echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
    fi
}

# 调用主菜单函数
MAIN_MENU
