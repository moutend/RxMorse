let Util = {
  emptyString: (n) => {
    let result = "";

    while(n) {
      result += " ";
      n -= 1;
    }

    return result;
  }
};

export default Util;
