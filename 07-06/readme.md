# Домашнее задание к занятию "7.6. Написание собственных провайдеров для Terraform."

## Задача 1. 
> Давайте потренируемся читать исходный код AWS провайдера, который можно склонировать от сюда: 
> [https://github.com/hashicorp/terraform-provider-aws.git](https://github.com/hashicorp/terraform-provider-aws.git).
> Просто найдите нужные ресурсы в исходном коде и ответы на вопросы станут понятны.  
> 
> 1. Найдите, где перечислены все доступные `resource` и `data_source`, приложите ссылку на эти строки в коде на 
> гитхабе.   
> 1. Для создания очереди сообщений SQS используется ресурс `aws_sqs_queue` у которого есть параметр `name`. 
>     * С каким другим параметром конфликтует `name`? Приложите строчку кода, в которой это указано.
>     * Какая максимальная длина имени? 
>     * Какому регулярному выражению должно подчиняться имя? 

1. [Доступные data_source](https://github.com/hashicorp/terraform-provider-aws/blob/6ece474a4ebcde9f10b7af1a70c85398393beaf5/internal/provider/provider.go#L345), [доступные resource](https://github.com/hashicorp/terraform-provider-aws/blob/6ece474a4ebcde9f10b7af1a70c85398393beaf5/internal/provider/provider.go#L741)
2.   
    * Информация о конфликте параметра `name` с параметром `name_prefix` приведена [здесь](https://github.com/hashicorp/terraform-provider-aws/blob/99ce18ec77baa78e28b11a3b39724f3a20cd2cd7/internal/service/sqs/queue.go#L87)
    * до версии v3.36.0 включительно параметр `name` проверялся в функции [validateSQSQueueName](https://github.com/hashicorp/terraform-provider-aws/blob/d29657d7a9ec98767a80eb403aff1773fb5eabe1/aws/validators.go#L1036):
        * содержимое поля ограничивалось [80 символами](https://github.com/hashicorp/terraform-provider-aws/blob/d29657d7a9ec98767a80eb403aff1773fb5eabe1/aws/validators.go#L1038);
        * содержимое поля должно было соответствовать регулярному выражению ["^[0-9A-Za-z-_]+(\.fifo)?$"](https://github.com/hashicorp/terraform-provider-aws/blob/d29657d7a9ec98767a80eb403aff1773fb5eabe1/aws/validators.go#L1042).
    * с версии v3.37.0 дополнительные проверки из провайдера были убраны (по крайней мере, в явном виде они не производятся). 