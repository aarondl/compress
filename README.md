README
======
**The purpose for this code is a personal learning experience and it is not
recommended that you use this code for anything other than a learning aid.**

Pack is an implementation of the zip file format using lz77 compression in a 
variety of languages. Languages intended to be included are: Go, Ruby, C++.

The source code is distributed with the MIT license which can be found in the
same directory as this readme file _(License.txt)_.

The various goals of this project are to produce code chunks as follows:

* An object that is capable of reading and interacting with the basics of the
zip file format.
* A stream that can wrap around a stream _(at the very least a filestream)_ 
and provide encoding on the fly.
* An encoding provider object that can take chunks of data and compress them.
