<?php

namespace Php\Package\Tests;

use PHPUnit\Framework\TestCase;
use Php\Package\Utils as UtilsClass;

// класс UtilsTest наследует класс TestCase
// имя класса совпадает с именем файла
class UtilsTest extends TestCase
{
    // Метод, функция определенная внутри класса
    // Должна начинаться со слова test
    // public – чтобы PHPUnit мог вызвать этот тест снаружи
    /**
     * @return void
     */
    public function testReverse(): void
    {
        // Сначала идет ожидаемое значение (expected)
        // И только потом актуальное (actual)
        $this->assertEquals('', (new UtilsClass)->reverseString(''));
        $this->assertEquals('olleh', (new UtilsClass)->reverseString('hello'));
    }
}