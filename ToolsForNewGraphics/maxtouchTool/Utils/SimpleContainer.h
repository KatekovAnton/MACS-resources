
#ifndef __SimpleContainer__
#define __SimpleContainer__

#include <vector>
#include <cstring>

namespace Utils {
    
    template<typename T>
    class SimpleContainer {
        T *_array;
        int         _count;
        int         _currentSize;
        
    public:
        
        T *GetArrayPointer() {return _array;};
        const T *GetArrayPointer() const {return _array;};
        
        
        SimpleContainer();
        SimpleContainer(int baseSize);
        ~SimpleContainer();
        
        void remove(int index);
        bool removeObject(const T& object);
        void addObject(const T& object);
        int indexOf(const T& object);
        void addPlace(unsigned int itemCount);
        void unsafeObjectsAdded(int count) { _count += count; }
        void AddObjects(const SimpleContainer<T>* objects);
        void clear();
        void replaceObjectAtIndex(int index, const T &object);
        T objectAtIndex(int index) const;
        void sort(int (* pointer)(const void *, const void *));
        int GetSize() const { return _currentSize; };
        int GetCount() const { return _count; };
        std::vector<T> ToSTDVector();
    };
    
    template <typename T>
    std::vector<T> SimpleContainer<T>::ToSTDVector() {
		std::vector<T> result;
        for (int i = 0; i < _count; i++) {
            result.push_back(_array[i]);
        }
        return result;
    }

    template <typename T>
    SimpleContainer<T>::SimpleContainer() {
		int baseSize = 100;
        _array = new T[baseSize];
        memset(_array, 0, sizeof(T) * baseSize);
        _currentSize = baseSize;
		_count = 0;
    }
    
    template<typename T>
    SimpleContainer<T>::SimpleContainer(int baseSize):_count(0) {
        _array = new T[baseSize];
        memset(_array, 0, sizeof(T) * baseSize);
        _currentSize = baseSize;
    }
    
    template <typename T>
    SimpleContainer<T>::~SimpleContainer() {
        clear();
        delete [] _array;
    }
    
    template <typename T>
    void SimpleContainer<T>::remove(int index) {
        if (index < _count) {
//            T obj  = _array[index];
            
            _array[index] = _array[_count - 1];
            _count--;
        }
    }
    
    template <typename T>
    int SimpleContainer<T>::indexOf(const T &object) {
         for (int i = 0; i < _count; i++) {
            if(_array[i] == object)
                return i;
        }
        return -1;
    }
    
    template <typename T>
    void SimpleContainer<T>::addPlace(unsigned int itemCount)
    {
        T *tmp = _array;
        _currentSize = _currentSize + itemCount;
        _array = new T[_currentSize];
        for (int i = 0; i < _count; i++)
            _array[i] = tmp[i];
        delete [] tmp;
    
        _count += itemCount;
    }

    template <typename T>
    void SimpleContainer<T>::clear() {
        delete [] _array;
        _array = new T[_currentSize];
        memset(_array, 0, _currentSize*sizeof(T));
        _count = 0;
    }
    
    template <typename T>
    bool SimpleContainer<T>::removeObject(const T& object) {
        for (int i = 0; i < _count; i++) {
            if (_array[i] == object) {
                remove(i);
                return true;
            }
        }
        return false;
    }
    
    template <typename T>
    void SimpleContainer<T>::addObject(const T& object) {
        if (_count == _currentSize) {
            T *tmp = _array;
            _currentSize = 2 * _currentSize;
            _array = new T[_currentSize];
            for (int i = 0; i < _count; i++)
                _array[i] = tmp[i];
            delete [] tmp;
        }
        _array[_count] = object;
        _count ++;
    }
    
    template <typename T>
    void SimpleContainer<T>::replaceObjectAtIndex(int index, const T &object)
    {
        _array[index] = object;
    }
    
    template <typename T>
    T SimpleContainer<T>::objectAtIndex(int index) const {
        T result = _array[index];
        return result;
    }
    
    template <typename T>
    void SimpleContainer<T>::sort(int (*pointer)(const void *, const void *)) {
        qsort(_array, _count, sizeof(T), pointer);
    }
    
    template <typename T>
    void SimpleContainer<T>::AddObjects(const SimpleContainer<T>* objects)
    {
        int newCount = _count + objects->GetCount();
        if (_currentSize < newCount)
        {
            int newSize = 2 * _currentSize;
            if (newSize < newCount)
                newSize = newCount;
            
            T *tmp = _array;
            _array = new T[newSize];
            for (int i = 0; i < _count; i++)
                _array[i] = tmp[i];
            
            _currentSize = newSize;
            delete [] tmp;
        }
        memcpy(_array + _count, objects->_array, objects->GetCount() * sizeof(T));
        
        _count = newCount;
    }
}

#endif /* defined(__SimpleContainer__) */
