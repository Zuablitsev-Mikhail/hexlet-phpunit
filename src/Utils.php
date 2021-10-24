<?php

namespace Php\Package;

/**
 * class Utils
 */
class Utils
{
    /**
     * @param $string
     * @return string
     */
    public function reverseString($string)
    {
        return implode(array_reverse(str_split($string)));
    }
}