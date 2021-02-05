/****************
 * 171044098    *
 * Akif Kartal  *
 * Homework 2   *
 ****************/
#include <iostream>
#include <fstream>
#define MAX_SIZE 100
using namespace std;
int CheckSumPossibility(int num, int arr[], int size);
void CheckSumPossibilityHelper(int num, int arr[], int size,
                               int total_sum, int current_sum, int index, int &res);
void test();//test function to test performance of the algorithm
int nofCount; //global variable number of function call
int main()
{
    int arraySize;
    int arr[MAX_SIZE];
    int num;
    int returnVal;

    cin >> arraySize;
    cin >> num;

    for (int i = 0; i < arraySize; ++i)
    {
        cin >> arr[i];
    }

    returnVal = CheckSumPossibility(num, arr, arraySize);

    if (returnVal == 1)
    {
        cout << "Possible!" << endl;
    }
    else
    {
        cout << "Not possible!" << endl;
    }
    cout << "Number of function calls: " << nofCount << endl; 
    //test();
    return 0;
}
/*
* Given function in homework, it used for some checking, initalizing
* and calling helper function.
* @param num target sum
* @param arr given array
* @param size array size
* @return 0 or 1 by using backtacking
*/
int CheckSumPossibility(int num, int arr[], int size)
{
    int total_sum = 0, current_sum = 0, index = 0, res = 0;
    nofCount = 0;
    //calculate total sum
    for (int i = 0; i < size; i++)
    {
        total_sum += arr[i];
    }
    //check extreme cases before backtracking.
    if (num <= 0 || total_sum < num){
        nofCount++;
        return 0;
    }
        
    if (total_sum == num){
        nofCount++;
        return 1;
    }
    // check with recursion
    CheckSumPossibilityHelper(num, arr, size, total_sum, current_sum, index, res);
    return res;
}
/*
* Helper recursive function.
* @param num target sum
* @param arr given array
* @param size array size
* @param total_sum total sum of elements
* @param current_sum sum of subsets
* @param index current array index
* @param res result of searching 
*/
void CheckSumPossibilityHelper(int num, int arr[], int size,
                               int total_sum, int current_sum, int index, int &res)
{

    if (current_sum == num) //base case 1
    {
        res = 1; // subset is found
        return;
    }
    if (index >= size) // base case 2
        return;
    else
    {
        if (current_sum + arr[index] <= num && res == 0)
        {
            nofCount++;
            //include current element into the sum and call again
            CheckSumPossibilityHelper(num, arr, size, total_sum - arr[index], current_sum + arr[index], index + 1, res);
        }
        if (current_sum + total_sum - arr[index] >= num && res == 0)
        {
            nofCount++;
            //don't include current element into the sum and call again
            CheckSumPossibilityHelper(num, arr, size, total_sum - arr[index], current_sum, index + 1, res);
        }
        else // ignore the next recursive calls if conditions are not match.
            return;
    }
}
/*
* test function to test performance of the algorithm from given
*example.txt file.
* It will find number of function call for each array then it will take the average of them.
*/
void test()
{
    ifstream inputFile("example.txt");
    ofstream outputFile("my_result.txt");
    int arr[MAX_SIZE];
    int x, returnVal,total_count=0;
    double avg;
    while (!inputFile.eof())
    {
        for (int i = 0; i < 10; i++)
        {
            inputFile >> arr[i];
        }
        inputFile >> x;
        outputFile << "The array is as follows: ";
        for (int i = 0; i < 10; i++)
        {
            outputFile << arr[i] << " ";
        }
        outputFile << endl << "The target number is: " << x << endl;
        returnVal = CheckSumPossibility(x, arr, 10);
        total_count+=nofCount;
        if (returnVal == 1)
        {
            outputFile << "The sequence giving the target number: " << x << endl;
            outputFile << "Possible!" << endl;
        }
        else
        {
            outputFile << "The sequence giving the target number: " << endl;
            outputFile << "Not possible!" << endl;
        }
        outputFile << "Number of function calls: " << nofCount << endl;
        outputFile << "-----------------------------------------------------" << endl;
    }
    avg=total_count/25.0;
    outputFile << "My number of function call average is: " << total_count << "/"<< 25 << " : "<< avg <<endl;
    inputFile.close();
    outputFile.close();
    cout << "File is created. Please check it." << endl;
}