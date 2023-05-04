using Newtonsoft.Json;

namespace Property
{
  static class Program
  {
    static void Main(string[] args)
    {
      string baseServiceUrl = @"https://property.melissadata.net/";
      string serviceEndpoint = @"v4/WEB/LookupProperty/"; //please see https://www.melissa.com/developer/property-data for more endpoints
      string license = "";
      string fips = "";
      string apn = "";

      ParseArguments(ref license, ref apn, ref fips, args);
      CallAPI(baseServiceUrl, serviceEndpoint, license, apn, fips);
    }

    static void ParseArguments(ref string license, ref string apn, ref string fips, string[] args)
    {
      for (int i = 0; i < args.Length; i++)
      {
        if (args[i].Equals("--license") || args[i].Equals("-l"))
        {
          if (args[i + 1] != null)
          {
            license = args[i + 1];
          }
        }
        if (args[i].Equals("--fips"))
        {
          if (args[i + 1] != null)
          {
            fips = args[i + 1];
          }
        }
        if (args[i].Equals("--apn"))
        {
          if (args[i + 1] != null)
          {
            apn = args[i + 1];
          }
        }
      }
    }

    public static async Task GetContents(string baseServiceUrl, string requestQuery)
    {
      HttpClient client = new HttpClient();
      client.BaseAddress = new Uri(baseServiceUrl);
      HttpResponseMessage response = await client.GetAsync(requestQuery);

      string text = await response.Content.ReadAsStringAsync();

      var obj = JsonConvert.DeserializeObject(text);
      var prettyResponse = JsonConvert.SerializeObject(obj, Newtonsoft.Json.Formatting.Indented);

      // Print output
      Console.WriteLine("\n=================================== OUTPUT ====================================\n");

      Console.WriteLine("API Call: ");
      string APICall = Path.Combine(baseServiceUrl, requestQuery);
      for (int i = 0; i < APICall.Length; i += 70)
      {
        try
        {
          Console.WriteLine(APICall.Substring(i, 70));
        }
        catch
        {
          Console.WriteLine(APICall.Substring(i, APICall.Length - i));
        }
      }
      Console.WriteLine("\nAPI Response:");
      Console.WriteLine(prettyResponse);
    }

    static void CallAPI(string baseServiceUrl, string serviceEndPoint, string license, string apn, string fips)
    {
      Console.WriteLine("\n================= WELCOME TO MELISSA PROPERTY CLOUD API ====================\n");

      bool shouldContinueRunning = true;

      while (shouldContinueRunning)
      {
        string inputFips = "";
        string inputApn = "";

        if (string.IsNullOrEmpty(fips) && string.IsNullOrEmpty(apn))
        {
          Console.WriteLine("\nFill in each value to see results");

          Console.Write("FIPS: ");
          inputFips = Console.ReadLine();

          Console.Write("APN: ");
          inputApn = Console.ReadLine();
        }
        else
        {
          inputFips = fips;
          inputApn = apn;
        }

        while (string.IsNullOrEmpty(inputFips) || string.IsNullOrEmpty(inputApn))
        {
          Console.WriteLine("\nFill in each value to see results");

          if (string.IsNullOrEmpty(inputFips))
          {
            Console.Write("FIPS: ");
            inputFips = Console.ReadLine();
          }

          if (string.IsNullOrEmpty(inputApn))
          {
            Console.Write("APN: ");
            inputApn = Console.ReadLine();
          }
        }

        Dictionary<string, string> inputs = new Dictionary<string, string>()
        {
            { "format", "json" },
            { "fips", inputFips },
            { "apn", inputApn }
        };

        Console.WriteLine("\n=================================== INPUTS ====================================\n");
        Console.WriteLine($"\t   Base Service Url: {baseServiceUrl}");
        Console.WriteLine($"\t  Service End Point: {serviceEndPoint}");
        Console.WriteLine($"\t               FIPS: {inputFips}");
        Console.WriteLine($"\t                APN: {inputApn}");

        // Create Service Call
        // Set the License String in the Request
        string RESTRequest = "";

        RESTRequest += @"&id=" + Uri.EscapeDataString(license);

        // Set the Input Parameters
        foreach (KeyValuePair<string, string> kvp in inputs)
          RESTRequest += @"&" + kvp.Key + "=" + Uri.EscapeDataString(kvp.Value);

        // Build the final REST String Query
        RESTRequest = serviceEndPoint + @"?" + RESTRequest;

        // Submit to the Web Service. 
        bool success = false;
        int retryCounter = 0;

        do
        {
          try //retry just in case of network failure
          {
            GetContents(baseServiceUrl, $"{RESTRequest}").Wait();
            Console.WriteLine();
            success = true;
          }
          catch (Exception ex)
          {
            retryCounter++;
            Console.WriteLine(ex.ToString());
            return;
          }
        } while ((success != true) && (retryCounter < 5));

        bool isValid = false;
        if (!string.IsNullOrEmpty(fips + apn))
        {
          isValid = true;
          shouldContinueRunning = false;
        }

        while (!isValid)
        {
          Console.WriteLine("\nTest another record? (Y/N)");
          string testAnotherResponse = Console.ReadLine();

          if (!string.IsNullOrEmpty(testAnotherResponse))
          {
            testAnotherResponse = testAnotherResponse.ToLower();
            if (testAnotherResponse == "y")
            {
              isValid = true;
            }
            else if (testAnotherResponse == "n")
            {
              isValid = true;
              shouldContinueRunning = false;
            }
            else
            {
              Console.Write("Invalid Response, please respond 'Y' or 'N'");
            }
          }
        }
      }

      Console.WriteLine("\n=============== THANK YOU FOR USING MELISSA CLOUD API ===============\n");
    }
  }
}
