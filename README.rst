py3-rocksdb
==========

Python-Bindings für RocksDB. Der Importname bleibt ``rocksdb``.

Version 0.7.0 ist ein ``py3-none-any``-Wheel mit der Erweiterung
``_rocksdb.cpython-310-x86_64-linux-gnu.so``. CPython 3.14 lädt diese Datei
nicht, deshalb endet ``import rocksdb`` mit
``ModuleNotFoundError: No module named 'rocksdb._rocksdb'``.

Diese Version baut die Erweiterung für den laufenden Interpreter. Getestet ist
die Binding-Basis mit CPython 3.11–3.14 und RocksDB 8.x–10.x. Auf Ubuntu 24.04
liefert ``librocksdb-dev`` RocksDB 8.9.1, das in diesem Bereich liegt.


Installation im Ubuntu-24.04-Container
--------------------------------------

Im Image mit Python 3.14 unter ``/usr/local`` die Systembibliothek und die
Übersetzerwerkzeuge installieren, das alte Paket entfernen und aus diesem
Quellbaum bauen::

    sudo apt-get update
    sudo apt-get install -y --no-install-recommends \
        build-essential pkg-config \
        librocksdb-dev libsnappy-dev zlib1g-dev libbz2-dev \
        liblz4-dev libzstd-dev libgflags-dev
    python3.14 -m pip uninstall -y py3-rocksdb
    python3.14 -m pip install .
    python3.14 -c "import rocksdb; db = rocksdb.DB('/tmp/rocks-smoke', rocksdb.Options(create_if_missing=True)); db.put(b'a', b'data'); assert db.get(b'a') == b'data'; print(rocksdb.__file__)"

Dasselbe macht ``scripts/build-ubuntu.sh``. Es legt zusätzlich ein
plattformspezifisches Wheel unter ``pip-package/`` ab. Der Dateiname muss
``cp314`` enthalten, nicht ``py3-none-any``.


Beispiel
--------

.. code-block:: python

    import rocksdb
    db = rocksdb.DB("test.db", rocksdb.Options(create_if_missing=True))
    db.put(b"a", b"data")
    print(db.get(b"a"))


Hinweise zum Wechsel von 0.7.0
------------------------------

* Python 3.10 und älter wird nicht mehr gebaut. Der laufende Container nutzt 3.14.
* RocksDB muss mindestens 8.0 sein. Die Header von Ubuntu 22.04 (RocksDB 6.11)
  reichen nicht.
* Einige alte ``Options``-Felder gibt es in RocksDB 8 nicht mehr, darunter
  ``max_background_compactions``, ``base_background_compactions`` und
  ``preserve_deletes``. Eigene Python-Filterpolicies werden nicht mehr
  unterstützt. ``BloomFilterPolicy`` bleibt.
* Bestehende Datenbanken, die mit RocksDB 6 geschrieben wurden, öffnet RocksDB
  8 in der Regel weiter. Vor dem Produktivlauf eine Kopie prüfen.


Herkunft
--------

Die Cython-Bindings stammen aus `f321x/python-rocksdb`_ 2.4.0, einer
Weiterführung der Forks von `twmht`_ und `NightTsarina`_. Die ursprünglichen
Bindings hat Stephan Hofmockel geschrieben. Lizenz: BSD-3-Clause.

.. _f321x/python-rocksdb: https://github.com/f321x/python-rocksdb
.. _twmht: https://github.com/twmht/python-rocksdb
.. _NightTsarina: https://github.com/NightTsarina/python-rocksdb
